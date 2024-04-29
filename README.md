# DBT Core & Snowflake Hands On Practices
## 2.1 Objectives
- To leverage sample data provided in Snowflake for building dbt models.
- To provide basic understanding on the folder structures in dbt folders and their repsective usage.
- Introduction to basic dbt commands.

## 2.2 Step-by-Step Guide
### Step 1: Sign Up for A Snowflake Trial Account
- Sign up for a Snowflake Trial Account via this [link](https://signup.snowflake.com/?utm_source=google&utm_medium=paidsearch&utm_campaign=ap-my-en-brand-productlogin-phrase&utm_content=go-rsa-evg-ss-free-trial&utm_term=c-g-snowflake%20net-p&_bt=591349680859&_bk=snowflake%20net&_bm=p&_bn=g&_bg=125204664862&gclsrc=aw.ds&gad_source=1&gclid=CjwKCAjw26KxBhBDEiwAu6KXt_n7Nh_Nk3mNBafetMGMnA7EnMRppqV-NdFloy2IZMjDWmDobW4CIRoCCtQQAvD_BwE). You will be given $400 credits and 30-days of trial period.

### Step 2: Snowflake Configuration
- Login to the newly created snowflake trial account.
- From the side panel, navigate to **Projects** > **Worksheets** and then select the **Folders** tab. Next, create a new folder - `dbt-snowflake demo` by clicking the **" + "** button on the right hand side. This folder will be used to store all the related demo worksheets. Refer to the image below for better visualisation. ![image](/images/image1.png)
- Within the folder, create a new worksheet and include the following codes:
	```sql
	-- Create Snowflake user for dbt
	USE ROLE accountadmin;
	CREATE USER IF NOT EXISTS dbt_user
	    PASSWORD = 'password'
	    LOGIN_NAME = dbt_user
	    DISPLAY_NAME = dbt_user
	    COMMENT = 'User for handling dbt development and production';
	
	-- Create new roles for dbt
	USE ROLE securityadmin;
	CREATE OR REPLACE ROLE dbt_dev_role;
	
	-- Grant the specific roles to the selected users
	GRANT ROLE dbt_dev_role TO USER dbt_user;
	GRANT ROLE dbt_dev_role TO ROLE sysadmin;
	
	-- Create snowflake virtual warehouse
	-- You can play with the warehouse's configurations
	USE ROLE sysadmin;
	CREATE OR REPLACE WAREHOUSE dbt_dev_wh WITH
	    WAREHOUSE_SIZE = 'MEDIUM'
	    AUTO_SUSPEND = 60
	    AUTO_RESUME = TRUE
	    MIN_CLUSTER_COUNT = 1
	    MAX_CLUSTER_COUNT = 1
	    INITIALLY_SUSPENDED = TRUE;
	
	-- Grant the permissions to fully access the warehouse to selected role
	GRANT ALL ON WAREHOUSE dbt_dev_wh TO ROLE dbt_dev_role;
	
	-- Create new daabase
	CREATE OR REPLACE DATABASE dbt_dev;
	
	-- Grant the permissions to fully access the database to selected role
	GRANT ALL ON DATABASE dbt_dev TO ROLE dbt_dev_role;
	```
	The above SQL script performs several administrative tasks in Snowflake:
	- Create a dbt User
	- Define Roles for dbt
	- Grant Roles
	- Set Up a Virtual Warehouse in Snowflake
	- Grant Permissions for Warehouse
	- Create a Database
	- Grant Permissions for Database

_**Remarks**_: _In this tutorial, full permissions are granted to the roles. However, in reality, it is necessary to grant only the minimal permissions or privileges that allow the tasks to be completed for each role_

### Step 3: Forking and Cloning the Repository for DBT-Snowflake Demo
- Fork this [demo-dbt-snowflake](https://github.com/jhwong97/demo-dbt-snowflake/tree/main/dbt_snowflake) repository
- Clone the forked repository to your local device.

### Step 4: Typical Directory Structures
- Once you have successfully cloned the forked repository onto your local device, navigate to the `dbt_snowflake` subfolder located within the cloned repository.
- The `dbt_snowflake` has the following directory structures:
	```cmd
	dbt_snowflake
	├── analyses
	├── dbt_project.yml
	├── macros
	├── models
	│   └── example
	│       ├── my_first_dbt_model.sql
	│       ├── my_second_dbt_model.sql
	│       └── schema.yml
	├── packages.yml
	├── profiles.yml
	├── seeds
	├── snapshots
	└── tests
	```
- The descriptions for each of the files and directories are as below:
	- `analyses`: This directory is mainly used for analytical queries but are not directly transformed into models.
	- `macros`: Macros are sets of SQL statements that you can reuse across your dbt project.
	- `models`: Contains the SQL files that define the transformations to create the analytics-ready data. Each model usually corresponds to a table or view in the database
	- `seeds`: his directory holds CSV files that dbt can load into your data warehouse as static data
	- `snapshots`: Contains SQL files that define how dbt captures changes to a specified dataset over time.
	- `tests`: This directory can be used to store custom data tests.
	- `dbt_project.yml`: The main configuration file for your dbt project. It defines project-specific configurations such as the dbt version requirement, model configurations, source data descriptions, and output settings
	- `packages.yml`: This file is used to manage dependencies of your dbt project
	- `profiles.yml`: This configuration file contains the details to connect to your data sources
	- `schema.yml`: A crucial role in defining and documenting the data models (metadata). Besides, it also helps in enforcing data quality through tests.

### Step 5: Testing dbt to Snowflake Connection
To setup the connection of this dbt repository with your personal Snowflake data warehouse, you are required to go through the following procedure:
- First, you are required to activate your virtual environment in `de-dbt-analytics` to use all the built-packages for this demo.
- After activating the virtual environment, navigate to the `dbt_snowflake` directory which is located inside the forked repository.
- Open the `profiles.yml` and you should see the below codes:
	```yml
	dbt_snowflake:
		outputs:
			dev:
				account: <organization_name>-<account_name>
				database: dbt_dev
				password: password
				role: dbt_dev_role
				schema: <schema_name>
				threads: 1
				type: snowflake
				user: dbt_user
				warehouse: dbt_dev_wh
		target: dev
	```
	- There are a few configurations that you need to amend:
		- For the `account`, you are required to replace the `<organization_name>` and `<account_name>` with your own value which can be found from your Snowflake URL after login. As example, for this Snowflake's sample URL - `https://app.snowflake.com/uavletx/htb11561/worksheets` the `<organization_name>` will be `uavletx` and the `<account_name>` is `htb11561`. Therefore, the final value will be `uavletx-htb11561`.
		- For the `schema`, you are required to replaced the `<schema_name>` with any name that suit your preferences. For example, `usr_alwong`.
	- Save the changes.
- Run the following command to test your dbt to Snowflake connections:
	```bash
	dbt debug --profiles-dir .
	```

- Run the following command to download all the dbt packages or dependencies:
	```bash
	dbt deps
	```

- Run the sample dbt models - `my_first_dbt_model.sql` and `my_second_dbt_model.sql` by executing the following command:
	```bash
	dbt run -m my_first_dbt_model my_second_dbt_model --profiles-dir .
	```
	
- Navigate to your Snowflake and under the **Data**, check if there is a new table - `MY_FIRST_DBT_MODEL` and a new view - `MY_SECOND_DBT_MODEL` created inside your schema as shown in the image below. 9: Try
- If everything run successfully, Congratz! You've set up your dbt to Snowflake connections.

### Step 6: Building dbt Models with Snowflake Sample Data
- In this section, you will learn the fundamental of creating dbt source, model, schema and test.
- Lets start with navigating to the models directory in the cloned repository by running this command:
	```cmd
	cd demo-dbt-snowflake/dbt_snowflake/models
	```
- Within the directory, you can see four (4) subfolders, namely:
	- `example`: The built-in example models when initializing the dbt which are demonstrated in Step 5.
	- `sowflake_sample_data`: A simple data query from snowflake sample data through dbt model.
	- `staging`: In this initial layer, raw data from source systems is loaded into staging models. These models often perform light transformations, such as renaming columns for consistency, converting data types, or handling missing values.
	- `transform`: This layer takes the cleaned data from the staging models and performs more complex transformations. These might include aggregating data, calculating business metrics, or joining data across different staging tables.
- Diving into each of the folder, you can find the following files and their respective roles.

| File Name|Description|
| ----- | ---- |
|`sources.yml` | It is a configuration for defining data sources in dbt, where it specifies the source of the raw data that will undergo transformations.|
|`tpch_query.sql`<br>`stg_customer__filtered_attributes.sql`<br> `stg_customer_address__filtered_attributes.sql`<br> `stg_customer_demographics__filtered_attributes.sql`<br> `tfm_customer__filetered_attributes.sql` | It is referred as the dbt model, where you can write your SQL statement inside it to query and transform data.                                                          |
| `tpch_query.yml`<br>`stg_customer__filtered_attributes.yml`<br>`stg_customer_address__filtered_attributes.yml`<br>`stg_customer_demographics__filtered_attributes.yml`<br>`tfm_customer__filetered_attributes.yml` | It is a `schema.yml` file where enriches it with metadata, descriptions, and test to ensure data integrity and to provide documentation for users and other developers. |
- _Remarks:_ Referring to the file name, you would notice that there is two distinct prefix:
    - stg_[source]__[entity].sql : This prefix stands for **staging**. Tables or models with this prefix are typically used as intermediate structures that hold raw data extracted directly from source systems.
    - fct_[source]__[entity].sql : This prefix stands for **fact**. Fact tables contain the quantitative data (or metrics) that a business wants to analyze, often keyed by foreign keys to dimension tables.
- Please take some time to review and understand the code in each file and understand how each file relates to each other.

### Step 7: Running dbt Models
- You can run the dbt model by executing this command `dbt run <model_name> --profiles-dir .`:
	```bash
	# Example
	dbt run stg_customer__filtered_attributes --profiles-dir .
	```

### Step 8: Runnng dbt Tests
- To run dbt test, you can run the following command `dbt test <model_name> --profiles-dir .`:
	```bash
	# Example
	dbt run stg_customer__filtered_attributes --profiles-dir .
	```
- To implement or alter the type of schema tests, you can edit the dbt `schema.yml` file under the **tests** section as shown in the image below.
![image](/images/image3.png)

- The most common generic tests include:
    - **Uniqueness**, which asserts that a column has no repeating values
    - **Not null**, which asserts that there are no null values in a column
    - **Referential integrity**, which tests that the column values have an existing relationship with a parent reference table
    - **Referential integrity**, which tests data against a freshness SLA based on a pre-defined timestamp
    - **Accepted values**, which checks if a field always contains values from a defined list
- For more information, kindly refer to this [What is dbt Testing? Definition, Best Practices, and More](https://www.montecarlodata.com/blog-what-is-dbt-testing-definition-best-practices-and-more/#:~:text=There%20are%20two%20primary%20ways,often%20work%20together%20within%20dbt.).

### Step 9: Summary
- Now that you've completed all the steps and grasped some of the basics of DBT, it's time for you to build your own DBT models and put them to the test.