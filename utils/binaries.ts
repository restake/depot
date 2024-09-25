import { getConfig } from "./config.ts";
import { DepotProject } from "./types.ts";

import { DEPOT_CONFIG_PATH, DEPOT_REPO_NAME, GITHUB_WORKSPACE } from "./config.ts";

export const getBinaries = async (repositoryName: string): Promise<Record<string, string>> => {
    const config = await getConfig(DEPOT_CONFIG_PATH) as DepotProject[];
    const project = config.find((project) => project.repository === repositoryName);

    if (!project) {
        throw new Error(`Project ${repositoryName} not found in config file`);
    }

    const binaries: Record<string, string> = {};

    if (project.binaries) {
        project.binaries.forEach((binary) => {
            binaries[binary] = `${GITHUB_WORKSPACE}/${project.project_name}/bin/${binary}-${project.cpu}-${project.architecture}`;
        });
        return binaries;
    }

    return binaries;
};

export const getDockerBinaries = async (repositoryName: string): Promise<string> => {
    const config = await getConfig(DEPOT_CONFIG_PATH) as DepotProject[];
    const project = config.find((project) => project.repository === repositoryName);

    if (!project) {
        throw new Error(`Project ${repositoryName} not found in config file`);
    }

    return project.docker_binaries?.join(',') ?? "";
}

if (DEPOT_REPO_NAME) {
    console.log(JSON.stringify(await getBinaries(DEPOT_REPO_NAME)));
} else {
    console.error("DEPOT_REPOSITORY_NAME is not set");
    Deno.exit(1);
}
