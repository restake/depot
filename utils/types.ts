export type DepotProject = {
    repository?: string;
    repository_org?: string;
    repository_name?: string;
    automatic_builds?: boolean;
    project_name: string;
    architecture: string;
    binaries: string[];
    builder: string;
    builder_version: string;
    binary_name: string;
    run_build?: boolean;
    docker_binaries?: string[];
    cpu: string;
    run_docker_build?: boolean;
    patches: boolean;
    purpose: string;
    runner?: string;
};
