export type DepotProject = {
    repository: string;
    name: string;
    architecture: string;
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
