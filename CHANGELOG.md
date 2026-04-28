### What's changed in v0.12.0

* chore(deps): update istio monorepo to v1.29.2 (#25) (by @renovate[bot])

  Co-authored-by: renovate[bot] <29139614+renovate[bot]@users.noreply.github.com>

* chore(makefile): add generate-configuration target (by @patrickleet)

  Wires hops validate generate-configuration as a prerequisite of
  validate:all / validate / validate:% so configuration.yaml is
  regenerated from upbound.yaml before each validation run.

  Implements [[tasks/update-xrd-makefiles-generate-config]]

* feat: aws lbc integration (by @patrickleet)


See full diff: [v0.11.0...v0.12.0](https://github.com/hops-ops/istio-stack/compare/v0.11.0...v0.12.0)
