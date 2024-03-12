import { Application, Router } from "https://deno.land/x/oak/mod.ts";
import { Context } from "https://deno.land/x/oak/mod.ts";
import { WebhookData } from "./types.ts";
import { triggerWorkflow } from "./trigger.ts";
import { getWorkflowConfig } from "./config.ts";

const app = new Application();
const router = new Router();

router.post("/webhook", async (context: Context) => {
  try {
    if (!context.request.hasBody) {
      throw new Error("Request body is missing");
    }

    const contentType = context.request.headers.get("content-type");

    if (!contentType || !contentType.includes("application/json")) {
      throw new Error("Invalid content type in request body");
    }

    const body: WebhookData = await context.request.body.json();
    //console.log("Received webhook payload:", body);
    context.response.body = "Webhook received successfully!";
    const [org, repo] = body.project.split("/");
    const config = getWorkflowConfig(repo);

    if (config) {
      triggerWorkflow(
        body.version,
        repo,
        org,
        config.protocol,
        config.binaryname,
        config.cpu,
        config.arch,
        config.purpose,
        config.patches
      );
    }
    console.log(`Update for ${config!.protocol}. Binaryname: ${config!.binaryname} and version: ${body.version} Arch: ${config!.arch}`)

  } catch (error) {
    console.error("Error processing webhook payload:", error);
    context.response.status = 500;
    context.response.body = "Internal Server Error";
  }
});

app.use(router.routes());
app.use(router.allowedMethods());

const PORT = Deno.env.get("PORT") || "3005";
console.log(`Server is running on port ${PORT}`);

await app.listen({ port: parseInt(PORT) });
