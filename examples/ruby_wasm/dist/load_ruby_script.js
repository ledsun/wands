// Copy from https://github.com/ruby/ruby.wasm/blob/8be5074c626691d08ccc994a6f683246db51f3c3/packages/npm-packages/ruby-wasm-wasi/src/browser.script.ts#L41
const mainWithRubyVM = async (vm) => {
  vm.printVersion();

  globalThis.rubyVM = vm;

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", () =>
      runRubyScriptsInHtml(vm)
    );
  } else {
    runRubyScriptsInHtml(vm);
  }
};

const runRubyScriptsInHtml = async (vm) => {
  const tags = document.querySelectorAll('script[type="text/ruby"]');

  const promisingRubyScripts = Array.from(tags).map((tag) =>
    loadScriptAsync(tag)
  );

  for await (const script of promisingRubyScripts) {
    if (script) {
      const { scriptContent, evalStyle } = script;
      switch (evalStyle) {
        case "async":
          vm.evalAsync(scriptContent);
          break;
        case "sync":
          vm.eval(scriptContent);
          break;
      }
    }
  }
};

const deriveEvalStyle = (tag) => {
  const rawEvalStyle = tag.getAttribute("data-eval") || "sync";
  if (rawEvalStyle !== "async" && rawEvalStyle !== "sync") {
    console.warn(
      `data-eval attribute of script tag must be "async" or "sync". ${rawEvalStyle} is ignored and "sync" is used instead.`
    );
    return "sync";
  }
  return rawEvalStyle;
};

const loadScriptAsync = async (tag) => {
  const evalStyle = deriveEvalStyle(tag);

  if (tag.hasAttribute("src")) {
    const url = tag.getAttribute("src");
    const response = await fetch(url);

    if (response.ok) {
      return { scriptContent: await response.text(), evalStyle };
    }

    return null;
  }

  return { scriptContent: tag.innerHTML, evalStyle };
};

import { DefaultRubyVM } from "https://cdn.jsdelivr.net/npm/@ruby/wasm-wasi@2.7.1/dist/browser/+esm";
const response = await fetch("/dist/ruby+gems.wasm");
const module = await WebAssembly.compileStreaming(response);
const { vm } = await DefaultRubyVM(module);

await mainWithRubyVM(vm);
