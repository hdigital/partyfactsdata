---
agent: 'agent'
description: 'Synchronize codebook.Rmd and codebook.md with consistent formatting.'
---

1. Render the RMarkdown file: `Rscript -e "rmarkdown::render('codebook.Rmd', output_format = 'md_document')"`
2. Format the generated Markdown: `uvx mdformat codebook.md`
3. Check changes with `git diff codebook.md` and apply formatting changes back to codebook.Rmd (except title):
   - **Title format**: Keep title in YAML front matter (ignore mdformat's addition of `# Title` heading)
   - **Line breaks**: Use backslash line breaks (`\`) before comparison operators that will be escaped at line start
   - **Escapes at line start**: Keep `\>`, `\<`, `\.` where they appear at the start of a line (pandoc adds these to avoid blockquote/list confusion)
   - **Inline operators**: Remove unnecessary escapes for `>`, `<` when they appear inline (mdformat removes these)
4. Repeat steps 1-2 to verify the output is stable (running render+format twice produces identical results)

**Minor differences are acceptable** if the output is stable (e.g., slight line-wrapping variations or quote character changes introduced by mdformat). The goal is stability, not perfection.

This ensures the source RMD file contains properly escaped markdown that survives the render+format cycle.

**Key insight**: Pandoc wraps text and escapes special characters at line start. Pre-format the Rmd to match where these line breaks and escapes will occur. The title remains in YAML for Rmd compatibility.
