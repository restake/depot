export type DepotProject = {
    repository: string;
    automatic_builds?: boolean;
    project_name: string;
    architecture: string;
    binaries: string[];
    docker_image_binaries?: string[];
    builder: string;
    builder_version: string;
    binary_name: string;
    cpu: string;
    patches: boolean;
    purpose: string;
};
