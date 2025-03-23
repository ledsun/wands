import fs from "fs/promises";
import path from "path";
import * as nodeWasi from "wasi";
import { RubyVM } from "@ruby/wasm-wasi";
import startEchoServer from "./start-echo-server.mjs";

async function instantiateNodeWasi() {
  const dirname = path.dirname(new URL(import.meta.url).pathname);
  const binaryPath = "../dist/ruby+wands.wasm";
  const binary = await fs.readFile(binaryPath);
  const rubyModule = await WebAssembly.compile(binary);

  const wasi = new nodeWasi.WASI({
    preopens: { "__root__": path.join(dirname, ".") },
    version: "preview1",
  });

  const { vm } = await RubyVM.instantiateModule({
    module: rubyModule,
    wasip1: wasi,
  });
  return vm;
}

async function test() {
  const vm = await instantiateNodeWasi();

  await vm.evalAsync(`
    require 'test/unit'

    require_relative '/__root__/tests/test_unit.rb'
    ok = Test::Unit::AutoRunner.run
    exit(1) unless ok
  `);
}

async function main() {
  const stopServer = startEchoServer(8080);

  try{
    Error.stackTraceLimit = Infinity;
    await test();
  } finally {
    stopServer();
  }
}

main();

