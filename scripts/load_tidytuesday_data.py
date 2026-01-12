from pathlib import Path
from pydytuesday import
import pandas as pd

def prepare_tidytuesday_data(date: str) -> dict:
    """
    Download and load all TidyTuesday datasets for a given date.

    Args:
        date (str): Date in 'YYYY-MM-DD' format.

    Returns:
        dict: A dictionary of dataset names mapped to pandas DataFrames.
    """
    # download all datasets for the given date
    folder = pydytuesday.get_date(date)
    data_dir = Path(folder)

    if not data_dir.exists():
        raise FileNotFoundError(f"No datasets found for {date}.")

    datasets = {}
    for csv_file in data_dir.glob("*.csv"):
        name = csv_file.stem
        try:
            df = pd.read_csv(csv_file)
            datasets[name] = df
            print(f"\n--- Loaded: {name} ---")
            print(df.info())
        except Exception as e:
            print(f"\n--- Failed to load {name}: {e} ---")

    if not datasets:
        raise ValueError(f"No CSV datasets loaded for {date}.")

    output_dir = Path(__file__).parent / "data"
    output_dir.mkdir(exist_ok=True)
    for name, df in datasets.items():
        df.to_csv(output_dir / f"{name}.csv", index=False)

    return datasets