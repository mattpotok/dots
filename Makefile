.PHONY: check fix

check:
	uv run ruff format --check dots-py src
	uv run ruff check dots-py src
	uv run ty check

fix:
	uv run ruff format dots-py src
	uv run ruff check --fix dots-py src
