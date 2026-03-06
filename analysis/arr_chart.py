import pandas as pd
import plotly.express as px

# Load data
df = pd.read_csv("arr_data.csv")

# Convert date
df["DATE_MONTH"] = pd.to_datetime(df["DATE_MONTH"])
df = df.sort_values("DATE_MONTH")

# Remove final 0 ARR
df = df[df["CUSTOMER_ARR"] > 0]

# Detect ARR changes
df["ARR_CHANGE"] = df["CUSTOMER_ARR"].diff()

change_points = df[df["ARR_CHANGE"] != 0]

fig = px.line(
    df,
    x="DATE_MONTH",
    y="CUSTOMER_ARR",
    markers=True,
    title="Customer ARR Evolution"
)

# Add annotations with box background
for _, row in change_points.iterrows():

    month_label = row["DATE_MONTH"].strftime("%b %Y")
    
    y_shift = -5 if month_label == "Oct 2022" else 20

    fig.add_annotation(
        x=row["DATE_MONTH"],
        y=row["CUSTOMER_ARR"],
        text=f"{month_label}<br>${int(row['CUSTOMER_ARR']):,}",
        showarrow=True,
        arrowhead=2,
        bgcolor="white",
        bordercolor="black",
        borderwidth=1,
        borderpad=4,
        yshift=y_shift,
        ay=40 if month_label == "Oct 2022" else -15
    )

fig.update_layout(
    xaxis_title="Month",
    yaxis_title="ARR (USD)",
    template="plotly_white"
)

fig.show()