import { getConfig } from "./config.ts";
import { getBinaries, getDockerBinaries } from "./binaries.ts";

import { DEPOT_CONFIG_PATH, DEPOT_REPO_NAME, DEPOT_REPOSITORY_ORG, GITHUB_ENV_PATH, GITHUB_IS_CI } from "./config.ts";
import { DepotProject } from "./types.ts";

const build = async (repositoryOrg: string, repositoryName: string): Promise<void> => {
    const config = await getConfig(DEPOT_CONFIG_PATH) as DepotProject[];

    let project = config.find((project) =>
        project.repository_org === repositoryOrg && project.repository_name === repositoryName
    );

    if (!project) {
        project = config.find((project) => project.repository === repositoryName);
    }

    if (!project) {
        throw new Error(`Project ${repositoryOrg}/${repositoryName} not found in config file`);
    }

    // Set automatic_builds to true by default
    const automaticBuilds = (project.automatic_builds && project.automatic_builds !== undefined) ?? true;
    const runBuild = (project.run_build && project.run_build !== undefined) ?? true;
    const runDockerBuild = (project.run_build && project.run_build !== undefined) ?? false;

    // Whether to build binaries automatically or not
    await setEnv("DEPOT_AUTOMATIC_BUILDS", automaticBuilds.toString());
    await setEnv("DEPOT_RUN_BUILD", runBuild.toString());
    await setEnv("DEPOT_RUN_DOCKER_BUILD", runDockerBuild.toString());

    // Set runner with default fallback
    const runner = project.runner || "ubuntu-22.04-l";
    await setEnv("DEPOT_RUNNER", runner);

        // The binaries we need to build for given project.
    if (runBuild === true) {
        await setEnv("DEPOT_BINARIES", await getProjectBinaryNames(project, "name"));
        await setEnv("DEPOT_BINARY_PATHS", await getProjectBinaryNames(project, "path"));
        await setEnv("DEPOT_BINARY_BUILD_NAME", await getProjectBinaryNames(project, "build"));

        // Only get Docker binaries if Docker builds are enabled
        if (project.run_docker_build === true) {
            let dockerRepoIdentifier: string;
            if (project.repository) {
                // Legacy
                dockerRepoIdentifier = project.repository;
            } else if (project.repository_org && project.repository_name) {
                dockerRepoIdentifier = `${project.repository_org}/${project.repository_name}`;
            } else {
                throw new Error(`Project ${project.project_name} has no valid repository identifier for docker binaries`);
            }

            await setEnv("DEPOT_DOCKER_BINARIES", await getDockerBinaries(dockerRepoIdentifier));
        } else {
            // Set empty docker binaries if Docker builds are disabled
            await setEnv("DEPOT_DOCKER_BINARIES", "");
        }
    }

    for (const key in project) {
        // Binaries and automatic_builds are a special case, we have already set these.
        if (key == "binaries" || key == "automatic_builds" || key == "run_build") {
            continue;
        } else if (project[key as keyof DepotProject] !== undefined) {
            await setEnv(`DEPOT_${key.toUpperCase()}`, project[key as keyof DepotProject] || "");
        }
    }
};

const setEnv = async (key: string, value: string | string[] | boolean): Promise<void> => {
    console.log(`>>> Setting ${key}=${value}`);
    // Environment variables are written to a file in GitHub Actions.
    if (GITHUB_IS_CI && GITHUB_ENV_PATH) {
        const randomNumber = getRandomNumber();
        await Deno.writeTextFile(GITHUB_ENV_PATH, `${key}<<EOD${randomNumber}\n`, { append: true });
        await Deno.writeTextFile(GITHUB_ENV_PATH, `${value}\n`, { append: true });
        await Deno.writeTextFile(GITHUB_ENV_PATH, `EOD${randomNumber}\n`, { append: true });
    }
};

const getProjectBinaryNames = async (project: DepotProject, target: string): Promise<string> => {
    let repoIdentifier: string;

    if (project.repository) {
        // Legacy
        repoIdentifier = project.repository;
    } else if (project.repository_org && project.repository_name) {
        repoIdentifier = `${project.repository_org}/${project.repository_name}`;
    } else {
        throw new Error(`Project ${project.project_name} has no valid repository identifier`);
    }

    const binaries = await getBinaries(repoIdentifier);
    return project.binaries.map((binary) => {
        if (target == "name") {
            return binaries[binary].split("/").pop();
        } else if (target == "path") {
            return binaries[binary];
        } else if (target == "build") {
            return binary;
        }
    }).join("\n");
};

const getRandomNumber = (): number => {
    return Math.floor(100000 + Math.random() * 900000);
};

if (DEPOT_REPO_NAME && DEPOT_REPOSITORY_ORG) {
    build(DEPOT_REPOSITORY_ORG, DEPOT_REPO_NAME);
} else {
    console.error("DEPOT_REPOSITORY_ORG or DEPOT_REPOSITORY_NAME is not set");
    Deno.exit(1);
}
