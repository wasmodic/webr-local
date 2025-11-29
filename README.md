# webR-local 

An extension of the [https://github.com/wasmodic/webr](https://github.com/wasmodic/webr) repository. 

The primary difference is that R functions are sourced from a package that is compiled to WAMm and hosted on a GitHub pages site.  

## How does the app work?
Look at the `<script/>` html section. R is started in a few key steps:

1. webR is imported, input and output html chunks are defined, and a new webR instance is made:

```javascript
import { WebR } from "https://webr.r-wasm.org/latest/webr.mjs";

const statusEl = document.getElementById("status");
const outputEl = document.getElementById("output");
const runBtn = document.getElementById("run");

const webR = new WebR();
```

2. Required R code is in a standard R package located at root of this repository and data is created in in a `webR.evalR()` command. Note that `await` is used since this is an asynchronous operation.

```javascript
    await webR.evalR(`
        webr::mount(mountpoint = "/wasmodicR", source = "https://wasmodic.github.io/webr-local/library.data");
        .libPaths(c(.libPaths(), "/wasmodicR"));
        library(wasmodicR);
        message("WasmodicR is loaded")
    `);
```

## How do data enter WASM here?
For the sequence input, they go into a html element defined as `seq`. These are then bound into `R` with `webR.objs.globalEnv.bind()`

```javascript
runBtn.addEventListener("click", async () => {
runBtn.disabled = true;
statusEl.textContent = "Running...";

const seq = document.getElementById("seq").value;

// Move input text into R
await webR.objs.globalEnv.bind("rawseq", seq);
```

Input is then processed like above in `webR.evalR()`

```javascript
const result = await webR.evalR(`
    library(stringr)

    seq_clean <- clean_seq(rawseq)
    gc <- gc_content(seq_clean)
    revseq <- rev_comp(seq_clean)

    paste(
        sprintf("Cleaned length: %d", gc$len),
        sprintf("GC bases: %d", gc$gc),
        sprintf("GC content: %.2f%%", gc$pct),
        "",
        "Reverse complement:",
        revseq,
        sep = "\\n"
    )
...)
```

## How do data exist WASM?
R output is captured in the result variable defined above and then handed back to the DOM via :

```javascript
const text = await result.toJs();
outputEl.textContent = text.values[0];
statusEl.textContent = "Done.";
runBtn.disabled = false;
```

## Questions:
- **What does captureStreams mean?**  
  When `true`, it captures R's console output (messages, warnings, prints). When `false`, it ignores console output and only returns the result value.

- **What does `result.toJS()` do?**  
  Converts R objects from webR's internal format into JavaScript objects that can be used in JavaScript code. The result has a `values` array containing the actual data.

- **What does `runBtn.disabled = false` mean?**  
  Re-enables the "Analyze sequence" button after processing is complete, allowing the user to click it again.
