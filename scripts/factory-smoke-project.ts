import { execFileSync, spawn } from "node:child_process";
import { mkdtempSync, rmSync } from "node:fs";
import os from "node:os";
import path from "node:path";
import process from "node:process";
import { createProject } from "../packages/create-voltagent-app/src/project-creator";
import type { ProjectOptions } from "../packages/create-voltagent-app/src/types";
import { createBaseDependencyInstaller } from "../packages/create-voltagent-app/src/utils/dependency-installer";

const log = (message: string): void => {
  console.log(`[factory:smoke] ${message}`);
};

const run = (command: string, args: string[], cwd: string): void => {
  log(`$ ${command} ${args.join(" ")}`);
  execFileSync(command, args, {
    cwd,
    stdio: "inherit",
  });
};

const verifyServiceStarts = async (cwd: string, timeoutMs: number): Promise<void> => {
  await new Promise<void>((resolve, reject) => {
    const child = spawn("npm", ["run", "start"], {
      cwd,
      stdio: "inherit",
    });

    let timedOut = false;
    let settled = false;
    let hardKillTimer: NodeJS.Timeout | null = null;

    const finish = (error?: Error): void => {
      if (settled) {
        return;
      }
      settled = true;
      clearTimeout(timer);
      if (hardKillTimer) {
        clearTimeout(hardKillTimer);
      }
      if (error) {
        reject(error);
        return;
      }
      resolve();
    };

    const timer = setTimeout(() => {
      timedOut = true;
      child.kill("SIGTERM");
      hardKillTimer = setTimeout(() => {
        child.kill("SIGKILL");
      }, 1500);
    }, timeoutMs);

    child.once("error", (error) => {
      finish(error);
    });

    child.once("exit", (code, signal) => {
      if (timedOut) {
        finish();
        return;
      }

      if (!settled) {
        const codePart = code === null ? "null" : `${code}`;
        const signalPart = signal ?? "none";
        finish(
          new Error(
            `start command exited before smoke timeout (code=${codePart}, signal=${signalPart})`,
          ),
        );
      }
    });
  });
};

const runWorkflowCycleAssertion = (cwd: string): void => {
  const assertionProgram = `
import { expenseApprovalWorkflow } from "./src/workflows";

const run = async () => {
  const execution = await expenseApprovalWorkflow.run({
  employeeId: "EMP-001",
  amount: 250,
  category: "office-supplies",
  description: "Factory smoke validation",
});

  if (execution.status !== "completed") {
    throw new Error("workflow execution status is not completed");
  }

  if (!execution.result) {
    throw new Error("workflow result is empty");
  }

  if (execution.result.status !== "approved") {
    throw new Error("workflow result status should be approved");
  }

  if (execution.result.approvedBy !== "system") {
    throw new Error("workflow should be auto-approved by system");
  }

  if (execution.result.finalAmount !== 250) {
    throw new Error("workflow finalAmount mismatch");
  }

  console.log("[factory:smoke] workflow cycle assertion passed");
  process.exit(0);
};

void run().catch((error) => {
  console.error(error);
  process.exit(1);
});
`;

  run("npm", ["exec", "tsx", "--", "--eval", assertionProgram], cwd);
};

const main = async (): Promise<void> => {
  const tempRoot = mkdtempSync(path.join(os.tmpdir(), "voltagent-factory-smoke-"));
  const projectName = "factory-smoke-app";
  const targetDir = path.join(tempRoot, projectName);
  const keepArtifacts = process.env.FACTORY_SMOKE_KEEP === "1";
  const startTimeoutMs = Number(process.env.FACTORY_SMOKE_START_TIMEOUT_MS ?? "5000");

  try {
    log(`scaffold target: ${targetDir}`);
    const options: ProjectOptions = {
      projectName,
      typescript: true,
      features: [],
      ide: "none",
      aiProvider: "ollama",
      server: "hono",
    };

    const installer = await createBaseDependencyInstaller(targetDir, projectName, "hono");
    await installer.waitForCompletion();
    await createProject(options, targetDir);

    run("npm", ["run", "build"], targetDir);
    await verifyServiceStarts(targetDir, startTimeoutMs);
    runWorkflowCycleAssertion(targetDir);

    log("init -> run -> cycle -> assert: passed");
  } finally {
    if (keepArtifacts) {
      log(`kept artifacts at ${tempRoot}`);
    } else {
      rmSync(tempRoot, { recursive: true, force: true });
    }
  }
};

void main();
