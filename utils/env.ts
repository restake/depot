import { getConfig } from "./config.ts";
import { getBinaries } from "./binaries.ts";

import { DEPOT_CONFIG_PATH, DEPOT_REPO_NAME, GITHUB_ENV_PATH, GITHUB_IS_CI } from "./config.ts";
import { DepotProject } from "./types.ts";

const build = async (repositoryName: string): Promise<void> => {
    const config = await getConfig(DEPOT_CONFIG_PATH) as DepotProject[];
    const project = config.find((project) => project.repository === repositoryName);
    if (!project) {
        throw new Error(`Project ${repositoryName} not found in config file`);
    }

    // The binaries we need to build for given project.
    await setEnv("DEPOT_BINARIES", await getProjectBinaries(project));

    for (const key in project) {
        // Binaries is a special case, we have already set it.
        if (key == "binaries") {
            continue;
        }
        await setEnv(`DEPOT_${key.toUpperCase()}`, project[key as keyof DepotProject]);
    }
};

const setEnv = async (key: string, value: string | string[] | boolean): Promise<void> => {
    // Convert arrays to newline separated strings.
    if (Array.isArray(value)) {
        value = value.join("\n");
    }

    console.log(`>>> Setting ${key}=${value}`);
    // Environment variables are written to a file in GitHub Actions.
    if (GITHUB_IS_CI && GITHUB_ENV_PATH) {
        const randomNumber = getRandomNumber();
        await Deno.writeTextFile(GITHUB_ENV_PATH, `${key}<<EOD${randomNumber}\n`, { append: true });
        await Deno.writeTextFile(GITHUB_ENV_PATH, `${value}\n`, { append: true });
        await Deno.writeTextFile(GITHUB_ENV_PATH, `EOD${randomNumber}\n`, { append: true });
    }
};

const getProjectBinaries = async (project: DepotProject): Promise<string> => {
    const binaries = await getBinaries(project.repository);
    return project.binaries.map((binary) => {
        return binaries[binary];
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
