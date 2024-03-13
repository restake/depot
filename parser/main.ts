import { parse } from "https://deno.land/std@0.207.0/yaml/mod.ts";
import { RepoData } from "./types.ts";

const path = "config.yml";
const envpath = Deno.env.get("GITHUB_ENV");

async function readYMLFile(filePath: string) {
  const file = await Deno.readTextFile(filePath);
  return parse(file);
}

async function setEnvvars(repositoryName: string) {
  const data: any = await readYMLFile(path);

  const repository = data.find((repo: RepoData) =>
    repo.repository === repositoryName
  );

  const multiLineBinaries = repository.binaries.map((binary: string) =>
    `${repository.name}/bin/${binary}-${repository.cpu}-${repository.architectures}`
  ).join("\n");

  console.log(multiLineBinaries);

  if (envpath) {

    await Deno.writeTextFile(envpath, `DEPOT_MULTILINE_BINARIES<<EOD111111\n`);
    await Deno.writeTextFile(envpath, `${multiLineBinaries}\n`, { append: true });
    await Deno.writeTextFile(envpath, `EOD111111\n`, { append: true });

    for (const key in repository) {
      if (key !== "binaries") {
        const envValue = repository[key];
        const envKey = `DEPOT_${key.toUpperCase()}`
        console.log(`>>> Setting ${envKey}=${envValue}`)
        const rand = generateRandomNumber()
        await Deno.writeTextFile(envpath, `${envKey}<<EOD${rand}\n`, { append: true });
        await Deno.writeTextFile(envpath, `${envValue}\n`, { append: true });
        await Deno.writeTextFile(envpath, `EOD${rand}\n`, { append: true });
      }
    }
  }
}

const protocol = Deno.env.get("DEPOT_REPOSITORY_NAME");

if (protocol) {
  setEnvvars(protocol);
}

function generateRandomNumber() {
  return Math.floor(100000 + Math.random() * 900000);
}
