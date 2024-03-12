export interface WorkflowConfig {
  protocol: string;
  binaryname: string;
  cpu: string;
  arch: string;
  purpose: string;
  patches: string;
}

const repoConfigs: Record<string, WorkflowConfig> = {
  "sui": {
    protocol: "sui",
    binaryname: "sui",
    cpu: "generic",
    arch: "x86_64",
    purpose: "node",
    patches: "false",
  },
  "composable-cosmos": {
    protocol: "centauri",
    binaryname: "centaurid",
    cpu: "generic",
    arch: "x86_64",
    purpose: "node",
    patches: "false",
  },
};

export function getWorkflowConfig(repo: string): WorkflowConfig | undefined {
  return repoConfigs[repo];
}
