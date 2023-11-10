#!/usr/bin/env node

const path = require('path')
const chokidar = require('chokidar')
const http = require('http')
const esbuild_sass = require("esbuild-sass-plugin");
const postcss = require("postcss");
const autoprefixer = require("autoprefixer");
const clients = []

http.createServer((req, res) => {
    return clients.push(
        res.writeHead(200, {
            "Content-Type": "text/event-stream",
            "Cache-Control": "no-cache",
            "Access-Control-Allow-Origin": "*",
            Connection: "keep-alive",
        }),
    );
}).listen(8082);

async function builder() {
    let js_result = await require("esbuild").build({
        entryPoints: ["app/javascript/application.js"],
        bundle: true,
        metafile: true,
        watch: true,
        incremental: true,
        outfile: "app/assets/builds/application.js",
        banner: {
            js: `
            (() => {
              try {
                const source = new EventSource("http://localhost:8082");
                source.onerror = () => {
                  source.close();
                };
                source.onmessage = () => location.reload();
              } catch (e) {
                if (!(e instanceof TypeError)) {
                  throw e;
                }
              }
            })();
          `
        }
    })
    let scss_result = await require("esbuild").build({
        entryPoints: ["app/assets/stylesheets/application.scss"],
        bundle: true,
        metafile: true,
        watch: true,
        incremental: true,
        outfile: "app/assets/builds/application.css",
        loader: {
            ".png": "file",
            ".jpg": "file",
            ".gif": "file",
            ".svg": "file",
            ".ttf": "file",
            ".woff": "file",
            ".woff2": "file",
            ".eot": "file",
        },
        plugins: [
            esbuild_sass.sassPlugin({
                async transform(source) {
                    const {css} = await postcss([autoprefixer]).process(source, {from: undefined});
                    return css;
                },
            }),
        ],
    })
    chokidar.watch(["./app/javascript/**/*.js", "./app/views/**/*.html.erb", "./app/components/**/*.html.erb", "./app/assets/builds/*.css"]).on('all', (event, path) => {
        if (path.includes("js")) {
            js_result.rebuild();
        }
        if (path.includes("css")) {
            scss_result.rebuild();
        }
        clients.forEach((res) => res.write('data: update\n\n'))
        clients.length = 0
    });
}

builder().catch((e) => {
    console.error(e);
    process.exit(1)
})