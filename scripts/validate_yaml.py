#!/usr/bin/env python3
"""
validate_yaml.py
Parcourt les YAML statiques (k8s/, argocd/) et vérifie leur syntaxe.
Les templates Helm (charts/*/templates/) sont validés par `helm lint` dans le CI.
Exit code 1 si une erreur est détectée — bloque le pipeline CI/CD.
"""

import sys
import os
import yaml

ROOT_DIRS = [
    os.path.join(os.path.dirname(__file__), "..", "k8s"),
    os.path.join(os.path.dirname(__file__), "..", "argocd"),
]
EXTENSIONS = (".yaml", ".yml")

errors = []
checked = 0

for root in ROOT_DIRS:
    if not os.path.isdir(root):
        continue
    for dirpath, _, filenames in os.walk(root):
        for filename in filenames:
            if not filename.endswith(EXTENSIONS):
                continue

            filepath = os.path.join(dirpath, filename)
            checked += 1

            try:
                with open(filepath, "r", encoding="utf-8") as f:
                    list(yaml.safe_load_all(f))
                print(f"  OK  {filepath}")
            except yaml.YAMLError as e:
                errors.append((filepath, str(e)))
                print(f"  FAIL  {filepath}\n       {e}")

print(f"\n{checked} fichier(s) verifie(s), {len(errors)} erreur(s) detectee(s).")

if errors:
    print("\nFichiers invalides :")
    for path, msg in errors:
        print(f"  - {path}")
    sys.exit(1)

print("Tous les fichiers YAML sont valides.")
sys.exit(0)
