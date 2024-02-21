import { parse } from "https://deno.land/std@0.207.0/yaml/mod.ts";

const cpu = Deno.env.get("BINARY_CPU");
const arch = Deno.env.get("BINARY_ARCH");
const protocol = Deno.env.get("BINARY_PROTOCOL");
const envpath = Deno.env.get("GITHUB_ENV");

async function readYAMLFile(filePath: string): Promise<OutputType> {
    try {
      const yamlContent = await Deno.readTextFile(filePath);
      return parse(yamlContent) as OutputType;
    } catch (error) {
      console.error(`Error reading YAML file: ${error.message}`);
      Deno.exit(1);
    }
}

type OutputType = {
    name: string;
    builder: string;
    builder_version: string;
    binary_name: string;
    architectures: string[];
    binaries: string[];
    dockerfile: string;
    dockerfile_binary: string;
  }[];

const output: OutputType = await readYAMLFile("config.yml")

for (const entry of output) {
    if (protocol == entry.name) {
        const multiLineBinaries = entry.binaries.map(binary => `${protocol}/bin/${binary}-${cpu}-${arch}`).join('\n');

        if (envpath) {
            console.log("Writing to env file");

            await Deno.writeTextFile(envpath, `ENVVAR_BINARIES<<EOD123456\n`)
            await Deno.writeTextFile(envpath, `${multiLineBinaries}\n`, { append: true });
            await Deno.writeTextFile(envpath, `EOD123456`, { append: true })

            const fileContent = await Deno.readTextFile(envpath);
            console.log(fileContent);
        } else {
            console.error("GITHUB_ENV environment variable not found. Unable to append to file.");
        }
    }
}
