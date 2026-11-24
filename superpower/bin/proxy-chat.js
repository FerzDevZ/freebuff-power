#!/usr/bin/env node
// ==============================================================================
// 💬 FREEBUFF-POWER INTERACTIVE TERMINAL CHAT (STREAMING REPL)
// ==============================================================================
const readline = require("readline");

const BASE_URL = process.env.FREEBUFF_PROXY_URL || "http://127.0.0.1:9187/v1";
const selectedModel = process.argv[2] || "z-ai/glm-5.3-flash";

const C_CYAN = "\x1b[36m";
const C_GREEN = "\x1b[32m";
const C_YELLOW = "\x1b[33m";
const C_PURPLE = "\x1b[35m";
const C_BOLD = "\x1b[1m";
const C_DIM = "\x1b[2m";
const C_RESET = "\x1b[0m";

const messages = [
  { role: "system", content: "You are an expert software engineer assistant powered by Freebuff Power." }
];

console.log(`${C_CYAN}${C_BOLD}================================================================================${C_RESET}`);
console.log(`${C_YELLOW}${C_BOLD}⚡ FREEBUFF-POWER INTERACTIVE CHAT REPL${C_RESET}`);
console.log(`${C_DIM}Proxy Endpoint: ${BASE_URL}${C_RESET}`);
console.log(`${C_GREEN}Active Model  : ${C_BOLD}${selectedModel}${C_RESET}`);
console.log(`${C_DIM}Ketik pertanyaan atau kode Anda. Perintah: /clear (reset percakapan), /exit (keluar)${C_RESET}`);
console.log(`${C_CYAN}${C_BOLD}================================================================================${C_RESET}\n`);

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  prompt: `${C_PURPLE}${C_BOLD}You ❯ ${C_RESET}`,
});

rl.prompt();

rl.on("line", async (line) => {
  const input = line.trim();
  if (!input) {
    rl.prompt();
    return;
  }

  if (input === "/exit" || input === "exit" || input === "quit") {
    console.log(`\n${C_YELLOW}Sampai jumpa! 👋${C_RESET}`);
    process.exit(0);
  }

  if (input === "/clear") {
    messages.length = 1;
    console.log(`\n${C_GREEN}🧹 Riwayat percakapan telah dibersihkan.${C_RESET}\n`);
    rl.prompt();
    return;
  }

  messages.push({ role: "user", content: input });
  process.stdout.write(`\n${C_CYAN}${C_BOLD}🤖 ${selectedModel} ❯ ${C_RESET}`);

  try {
    const res = await fetch(`${BASE_URL}/chat/completions`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer freebuff",
      },
      body: JSON.stringify({
        model: selectedModel,
        messages: messages,
        stream: true,
      }),
    });

    if (!res.ok) {
      const errText = await res.text();
      console.log(`\n\x1b[31m[Error ${res.status}]: ${errText}\x1b[0m\n`);
      rl.prompt();
      return;
    }

    let assistantReply = "";
    const reader = res.body.getReader();
    const decoder = new TextDecoder("utf-8");
    let buffer = "";

    while (true) {
      const { done, value } = await reader.read();
      if (done) break;

      buffer += decoder.decode(value, { stream: true });
      const lines = buffer.split("\n");
      buffer = lines.pop(); // keep partial line

      for (const rawLine of lines) {
        const trimmed = rawLine.trim();
        if (!trimmed || !trimmed.startsWith("data:")) continue;
        const dataStr = trimmed.replace(/^data:\s*/, "");
        if (dataStr === "[DONE]") break;

        try {
          const parsed = JSON.parse(dataStr);
          const token = parsed.choices?.[0]?.delta?.content || "";
          if (token) {
            process.stdout.write(token);
            assistantReply += token;
          }
        } catch {
          // ignore partial JSON parse
        }
      }
    }

    messages.push({ role: "assistant", content: assistantReply });
    console.log("\n");
  } catch (err) {
    console.log(`\n\x1b[31m[Fetch Error]: ${err.message}\x1b[0m\n`);
  }

  rl.prompt();
});

rl.on("close", () => {
  console.log(`\n${C_YELLOW}Sesi ditutup.${C_RESET}`);
  process.exit(0);
});
