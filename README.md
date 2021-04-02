# socialgouv/dashlord-init-action

Parse a `dashlord.yaml` or `urls.txt` file to generate a list of urls to use in a GitHub action jobs matrix.

## Usage

See how `needs.init.outputs.urls_json` is used in the matrix definition

```yaml
jobs:
  init:
    runs-on: ubuntu-latest
    outputs:
      urls: ${{ steps.init.outputs.urls }}
      urls_json: ${{ steps.init.outputs.urls_json }}
    steps:
      - uses: actions/checkout@v2
      - id: init
        uses: "socialgouv/dashlord-init-action"

  scans:
    runs-on: ubuntu-latest
    needs: init
    strategy:
      fail-fast: false
      max-parallel: 3
      matrix:
        url: ${{ fromJson(needs.init.outputs.urls_json) }}
    steps: ...
```

### Expected dashlord.yaml

```yml
title: Test 1
urls:
  - url: https://www.free.fr
    title: Some website
  - url: invalid-url
  - url: http://chez.com
```
