from pathlib import Path

import pandas as pd


PROJECT_DIR = Path(__file__).resolve().parent.parent
RAW_DIR = PROJECT_DIR / "Data" / "Raw Data"
CLEAN_DIR = PROJECT_DIR / "Data" / "Cleaned Data"

CLEAN_DIR.mkdir(parents=True, exist_ok=True)


def load_datasets():
    return {
        "customers": pd.read_csv(RAW_DIR / "customers.csv"),
        "accounts": pd.read_csv(RAW_DIR / "accounts.csv"),
        "cards": pd.read_csv(RAW_DIR / "cards.csv"),
        "loans": pd.read_csv(RAW_DIR / "loans.csv"),
        "branches": pd.read_csv(RAW_DIR / "branches.csv"),
        "merchants": pd.read_csv(RAW_DIR / "merchants.csv"),
    }


def main():
    datasets = load_datasets() #store all datasets in a dictionary

    print("\nDATASET SHAPES")
    for name, dataframe in datasets.items():
        print(f"{name}: {dataframe.shape[0]} rows, {dataframe.shape[1]} columns")

    missing_reports = []

    for name, dataframe in datasets.items():
        print(f"\n{name.upper()}")
        print(dataframe.head())
        print("\nData types:")
        print(dataframe.dtypes)

        report = pd.DataFrame(
            {
                "dataset": name,
                "column": dataframe.columns,
                "missing_values": dataframe.isna().sum().values,
                "missing_percentage": (
                    dataframe.isna().mean().values * 100
                ).round(2),
            }
        )

        missing_reports.append(report)

    missing_report = pd.concat(missing_reports, ignore_index=True)

    missing_report.to_csv(
        CLEAN_DIR / "missing_values_report.csv",
        index=False,
    )

    print("\nMissing-value report saved.")


 # Check completely duplicated rows.
    print("\nDUPLICATE ROWS")

    for name, dataframe in datasets.items():
        duplicate_rows = dataframe.duplicated().sum()
        print(f"{name}: {duplicate_rows}")

    # Check duplicated primary IDs.
    primary_keys = {
        "customers": "customer_id",
        "accounts": "account_id",
        "cards": "card_id",
        "loans": "loan_id",
        "branches": "branch_id",
        "merchants": "merchant_id",
    }

    print("\nDUPLICATE PRIMARY IDS")

    for name, primary_key in primary_keys.items():
        dataframe = datasets[name]

        duplicate_ids = dataframe[primary_key].duplicated().sum()

        print(
            f"{name}: {duplicate_ids} duplicate values "
            f"in {primary_key}"
        )

    # Check duplicated emails.
    emails = {
        "customers": "email",
    }

    print("\nDUPLICATE EMAILS")

    for name, emails in emails.items():
        dataframe = datasets[name]

        duplicate_emails = dataframe[emails].duplicated().sum()

        print(
            f"{name}: {duplicate_emails} duplicate values "
            f"in {emails}"
        )

    # Check relationships between datasets.
    orphan_accounts = datasets["accounts"][
        ~datasets["accounts"]["customer_id"].isin(
            datasets["customers"]["customer_id"]
        )
    ]

    orphan_cards = datasets["cards"][
        ~datasets["cards"]["account_id"].isin(
            datasets["accounts"]["account_id"]
        )
    ]

    orphan_loans = datasets["loans"][
        ~datasets["loans"]["customer_id"].isin(
            datasets["customers"]["customer_id"]
        )
    ]

    print("\nORPHAN RECORDS")
    print("Orphan accounts:", len(orphan_accounts))
    print("Orphan cards:", len(orphan_cards))
    print("Orphan loans:", len(orphan_loans))


if __name__ == "__main__":
    main()