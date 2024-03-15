import { parse } from "https://deno.land/std@0.207.0/yaml/mod.ts";

const DEPOT_CONFIG_PATH = "config.yml";
const DEPOT_REPO_NAME = Deno.env.get("DEPOT_REPOSITORY_NAME") ?? "composable-cosmos";

const GITHUB_ENV_PATH = Deno.env.get("GITHUB_ENV");
const GITHUB_IS_CI = Deno.env.get("CI");

export type DepotProject = {
    repository: string;
    name: string;
    architectures: string[];
    binaries: string[];
    builder: string;
    builder_version: string;
    binary_name: string;
    cpu: string;
    dockerfile: string;
    dockerfile_binary: string;
    patches: boolean;
    purpose: string;
};

export const build = async (repositoryName: string): Promise<void> => {
    const config = await getConfig(DEPOT_CONFIG_PATH) as DepotProject[];
    const project = config.find((project) =>
        project.repository === repositoryName
    );
    if (!project) {
        throw new Error(`Project ${repositoryName} not found in config file`);
    }

    // The binaries we need to build for given project.
    await setEnv("DEPOT_BINARIES", getProjectBinaries(project));

    for (const key in project) {
        // Binaries is a special case, we have already set it.
        if (key == "binaries") {
            continue;
        }
        await setEnv(`DEPOT_${key.toUpperCase()}`, project[key as keyof DepotProject]);
    }
}

const setEnv = async (key: string, value: string | string[] | boolean): Promise<void> => {
    // Convert arrays to newline separated strings.
    if (Array.isArray(value)) {
        value = value.join("\n");
    }

    console.log(`>>> Setting ${key}=${value}`)
    // Environment variables are written to a file in GitHub Actions.
    if (GITHUB_IS_CI && GITHUB_ENV_PATH) {
        const randomNumber = getRandomNumber();
        await Deno.writeTextFile(GITHUB_ENV_PATH, `${key}<<EOD${randomNumber}\n`, { append: true });
        await Deno.writeTextFile(GITHUB_ENV_PATH, `${value}\n`, { append: true });
        await Deno.writeTextFile(GITHUB_ENV_PATH, `EOD${randomNumber}\n`, { append: true });
    }
};

const getProjectBinaries = (project: DepotProject) => {
    return project.binaries.flatMap(binary => project.architectures.map(arch => {
        return `${project.name}/bin/${binary}-${project.cpu}-${arch}`
    })).join("\n");
};

const getRandomNumber = () => {
    return Math.floor(100000 + Math.random() * 900000);
};

const getConfig = async (filepath: string) => {
    try {
        const config = await Deno.readTextFile(filepath);
        return parse(config);
    } catch (error) {
        throw new Error("Error reading config file", {
            cause: error
        });
    }
};

if (DEPOT_REPO_NAME) {
    build(DEPOT_REPO_NAME);
}
