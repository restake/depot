export type DepotProject = {
    repository: string;
    project_name: string;
    architecture: string;
    binaries: string[];
    builder: string;
    builder_version: string;
    binary_name: string;
    cpu: string;
    patches: boolean;
    purpose: string;
};
