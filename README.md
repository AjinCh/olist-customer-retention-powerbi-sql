# Olist Customer Retention & Revenue Analytics

A comprehensive SQL and Power BI analytics project for the Olist e-commerce dataset, featuring in-depth analysis of customer retention, revenue trends, RFM segmentation, delivery performance, and customer satisfaction metrics.

## 📊 Project Overview

This project combines PostgreSQL database management with Power BI visualization to provide actionable business intelligence for the Olist Brazilian e-commerce platform. The analysis focuses on understanding customer behavior, identifying retention patterns, and optimizing operational performance across multiple dimensions.

### Key Metrics Analyzed
- **Revenue Analytics**: Monthly trends, category performance, and average order value
- **Customer Retention**: Repeat purchase behavior, customer lifetime value, and churn analysis
- **RFM Segmentation**: Recency, Frequency, and Monetary analysis for customer segmentation
- **Delivery Performance**: On-time delivery rates and carrier performance
- **Customer Satisfaction**: Review scores and customer feedback analysis

## 📁 Project Structure

```
olist-customer-retention-powerbi-sql/
├── data/                          # Raw datasets
│   ├── olist_customers_dataset.csv
│   ├── olist_orders_dataset.csv
│   ├── olist_order_items_dataset.csv
│   ├── olist_order_payments_dataset.csv
│   ├── olist_order_reviews_dataset.csv
│   ├── olist_products_dataset.csv
│   ├── olist_sellers_dataset.csv
│   ├── olist_geolocation_dataset.csv
│   └── product_category_name_translation.csv
├── sql/                           # SQL scripts
│   ├── create_tables.sql          # Database schema and table creation
│   └── create_views.sql           # Analytical views for Power BI
├── powerbi/                       # Power BI dashboard
│   └── Olist_Customer_Retention_Revenue_Analytics.pbix
├── screenshots/                   # Dashboard previews
│   ├── executive_overview.png
│   ├── customer_retention.png
│   ├── delivery_satisfaction.png
│   └── business_recommendations.png
└── README.md
```

## 🗄️ Database Schema

### Tables
The project uses 8 main tables to structure the Olist dataset:

- **customers**: Customer profiles with geographic information
- **orders**: Order header information with status and timestamps
- **order_items**: Line items with product and pricing details
- **order_payments**: Payment methods and transaction data
- **order_reviews**: Customer ratings and feedback
- **products**: Product catalog with attributes
- **sellers**: Seller information and locations
- **product_category_translation**: Portuguese to English category mapping

### Analytical Views
The project includes 5 key analytical views:

1. **vw_monthly_revenue**: Monthly revenue trends, order counts, and average order value
2. **vw_product_category_performance**: Category-level sales, revenue, and pricing analytics
3. **vw_state_revenue_performance**: Geographic revenue analysis by customer state
4. **vw_payment_type_performance**: Payment method analysis with installment trends
5. **vw_customer_repeat_behavior**: Customer purchase frequency and lifetime value

## 🚀 Getting Started

### Prerequisites
- PostgreSQL (or compatible SQL database)
- Power BI Desktop
- Basic SQL knowledge

### Setup Instructions

1. **Create the database schema**
   - Run `sql/create_tables.sql` to set up all tables
   - Run `sql/create_views.sql` to create analytical views

2. **Import data**
   - Import CSV files from the `data/` directory into their corresponding tables
   - Ensure proper encoding and data type mappings

3. **Connect Power BI**
   - Open `powerbi/Olist_Customer_Retention_Revenue_Analytics.pbix`
   - Configure database connection to your PostgreSQL instance
   - Refresh data to load the latest analytics

## 📈 Dashboard Features

### Executive Overview
High-level business metrics including total revenue, orders, customers, and key performance indicators.

### Customer Retention Analysis
Deep dive into repeat purchase patterns, customer segments, and retention cohorts.

### Delivery & Satisfaction
Logistics performance metrics and customer satisfaction scores across delivery channels.

### Business Recommendations
Actionable insights and strategic recommendations based on data analysis.

## 💡 Key Insights

The analysis provides insights into:
- Which product categories drive the most revenue
- Customer geographic distribution and regional performance
- Payment preferences and installment trends
- Delivery reliability and its impact on customer satisfaction
- Customer retention opportunities and churn risk factors

## 📊 Technology Stack

- **Database**: PostgreSQL
- **Visualization**: Microsoft Power BI
- **Data**: Olist Brazilian E-commerce Public Dataset
- **Version Control**: Git

## 📝 Dataset Information

The data comes from the Olist Brazilian E-commerce Public Dataset containing 100K+ orders from 2016-2018. For more information, visit the [Olist dataset on Kaggle](https://www.kaggle.com/olistbr/brazilian-ecommerce).

## 🤝 Contributing

Contributions and improvements are welcome! Feel free to:
- Add additional analytical views
- Enhance Power BI visualizations
- Optimize SQL queries
- Improve documentation

## 📄 License

This project is provided as-is for educational and analytical purposes.

---

**Last Updated**: May 2026
