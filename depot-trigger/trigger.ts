import { App, Octokit } from "https://esm.sh/octokit?dts";

export async function triggerWorkflow(
  version: string,
  repo: string,
  organization: string,
  protocol: string,
  binaryname: string,
  cpu: string,
  arch: string,
  purpose: string,
  patches: string,
) {
  const token = "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"
  const workflow_owner = "restake"
  const workflow_repo = "depot"
  const workflow_id = "build-binary.yml"

  const octokit = new Octokit({
    auth: token,
  });

  const response = await octokit.request(
    `POST /repos/${workflow_owner}/${workflow_repo}/actions/workflows/${workflow_id}/dispatches`,
    {
      //owner: workflow_owner,
      //repo: workflow_repo,
      //workflow_id,
      ref: "feature/RI-1008",
      inputs: {
        // Values coming from the webhook
        version,
        repository: repo,
        organization,
        protocol,
        //Name of the built binaries file (ie. sui, neard, centaurid)
        binaryname,
        cpu,
        arch,
        //Purpose of the built binary (ie. node, tool)
        purpose,
        //If patches are applicable
        patches,
      },
      headers: {
        'X-GitHub-Api-Version': '2022-11-28',
      },
    },
  );

  console.log("Workflow triggered:", response.status);
}

//await triggerWorkflow("v1.18.22","composable-cosmos","ComposableFi","centauri","centaurid","generic","x86_64","node","false");
