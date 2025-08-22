import { parse } from "https://deno.land/std@0.207.0/yaml/mod.ts";

export const GITHUB_ENV_PATH = Deno.env.get("GITHUB_ENV");
export const GITHUB_IS_CI = Deno.env.get("CI");
export const GITHUB_WORKSPACE = Deno.env.get("GITHUB_WORKSPACE") ?? Deno.cwd();

export const DEPOT_CONFIG_PATH = `${GITHUB_WORKSPACE}/config.yml`;
export const DEPOT_REPO_NAME = Deno.env.get("DEPOT_REPOSITORY_NAME") ?? "sui";
export const DEPOT_REPOSITORY_ORG = Deno.env.get("DEPOT_REPOSITORY_ORG") ?? "sui";

export const getConfig = async (filepath: string) => {
    try {
        const config = await Deno.readTextFile(filepath);
        return parse(config);
    } catch (error) {
        throw new Error("Error reading config file", {
            cause: error,
        });
    }
};
