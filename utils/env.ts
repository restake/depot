import { getConfig } from "./config.ts";
import { getBinaries, getDockerBinaries } from "./binaries.ts";

import { DEPOT_CONFIG_PATH, DEPOT_REPO_NAME, GITHUB_ENV_PATH, GITHUB_IS_CI } from "./config.ts";
import { DepotProject } from "./types.ts";

const build = async (repositoryName: string): Promise<void> => {
    const config = await getConfig(DEPOT_CONFIG_PATH) as DepotProject[];
    const project = config.find((project) => project.repository === repositoryName);
    if (!project) {
        throw new Error(`Project ${repositoryName} not found in config file`);
    }

    // Set automatic_builds to true by default
    const automaticBuilds = (project.automatic_builds && project.automatic_builds !== undefined) ?? true;

    // Whether to build binaries automatically or not
    await setEnv("DEPOT_AUTOMATIC_BUILDS", automaticBuilds.toString());

    // The binaries we need to build for given project.
    await setEnv("DEPOT_BINARIES", await getProjectBinaryNames(project, "name"));
    await setEnv("DEPOT_BINARY_PATHS", await getProjectBinaryNames(project, "path"));
    await setEnv("DEPOT_BINARY_BUILD_NAME", await getProjectBinaryNames(project, "build"));
    await setEnv("DEPOT_DOCKER_IMAGE_BINARIES", await getDockerImageBinaries(project));

    for (const key in project) {
        // Binaries and automatic_builds are a special case, we have already set these.
        if (key == "binaries" || key == "automatic_builds" || key == "docker_image_binaries") {
            continue;
        } else if (project[key as keyof DepotProject] !== undefined) {
            await setEnv(`DEPOT_${key.toUpperCase()}`, project[key as keyof DepotProject] || "");
        }
    }
};

const setEnv = async (key: string, value: string | string[] | boolean): Promise<void> => {
    // Convert arrays to newline separated strings.
    // if (Array.isArray(value)) {
    //     value = value.join("\n");
    // }

    console.log(`>>> Setting ${key}=${value}`);
    // Environment variables are written to a file in GitHub Actions.
    if (GITHUB_IS_CI && GITHUB_ENV_PATH) {
        const randomNumber = getRandomNumber();
        await Deno.writeTextFile(GITHUB_ENV_PATH, `${key}<<EOD${randomNumber}\n`, { append: true });
        await Deno.writeTextFile(GITHUB_ENV_PATH, `${value}\n`, { append: true });
        await Deno.writeTextFile(GITHUB_ENV_PATH, `EOD${randomNumber}\n`, { append: true });
    }
};

const getDockerImageBinaries = async (project: DepotProject): Promise<string> => {
    const binaries = await getDockerBinaries(project.repository);
    return binaries.join(",")
};

const getProjectBinaryNames = async (project: DepotProject, target: string): Promise<string> => {
    const binaries = await getBinaries(project.repository);
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

if (DEPOT_REPO_NAME) {
    build(DEPOT_REPO_NAME);
} else {
    console.error("DEPOT_REPOSITORY_NAME is not set again");
    Deno.exit(1);
}
