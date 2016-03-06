# Dash
Hanzo's dashboard is designed for use by developers, support members and
executives of a given organization. Ideally all marketing and most of the
support operations can be performed via it.

The dashboard is composed of modules, each representing an orthogonal collection
of features. Each module contains a set of views which are typically accessible
from the dashboard sidebar. Each module can be used independently of each other,
but frequently modules extend functionality in other modules.

# Goals

## For us
- Adding new views and modules should be straightforward
- Consistent layout / organization
- Composable, reusable views and widgets
- Optimized development process and rapid iteration
- Onboarding new organizations should be fast and straight-forward
- Should streamline marketing efforts we perform

## For organizations
- Access to real-time ecommerce statistics
- Analytics/Reporting (mostly powered by GoodData)
- Ecommerce support functionality
- Able to edit orders
- Interact with customers
- Send marketing emails
- Resend order confirmations
- Credit accounts, etc.
- Flexible enough to support diverse needs
- Provide support for launching, growing and maintaining commerce-driven companies
- Analytics integrations
- Authentication / User management
- Ecommerce / Order management
- Marketing APIs / customer interaction
- Easy to navigate and discover functionality / features
- Ability to configure integrations with third-party services
- New organizations need fewer features, expect functionality used to grow over time

# Architecture

## REST API
- Provides predictable CRUD operations across all models
- Provides specialized ecommerce/marketing/support functionality

## Search API
- Returns heterogeneous results
- Easy to filter to a single model
- Complex filtering possible
- Any combination of properties across all models
    - Date ranges, numeric ranges, text, etc.
- Majority of properties on models are indexed and full-text searchable

## Dash API
- Ability to find fields across dashboard in enabled modules and/or text content

## Statistics API
- Possible to return real-time statistics for campaigns, products, orders, users, etc
- Aggregated at hour, day, month, total

## GoodData API
- Provides advanced analytics & reporting

## Dashboard
- Hosted using our Site publishing API
- Generated using static site generated
- Fully cached/static, driven by various APIs

# Glossary

## Module
- A set of views that accessible from sidebar
- Should provide orthogonal functionality
- Should be independent of all other modules
- Possible to install / enable individually
- Static generated, functionality powered by REST API
- May provide functionality to other modules
- Typically enables a set of API endpoints
    - Order module enables `api.hanzo.io/order` API, etc.
- Each module is unique and navigable to from search
- Each module landing page / start view provides
    - Last 10 updated models
    - Common functionality
    - Onboarding information
    - Basic statistics / graphs
    - Insights about changes in performance

## View
- A given page / collection of widgets, generally part of a set of views provided by a module
- Discoverable via secondary menu in sidebar
- Each view is unique and navigable to from search
- Functionality dictates design
- Unique, optimized layouts preferred per view

## Widget
- Individual form, graph or input.
- Each widget instance is unique and navigable to from search

## Sidebar
- Lists modules
- Modules are (possibly) pinnable
- Secondary menu with links to each view per module

## Search bar
- Provides quick access to all models + views / widgets

# Modules
Each module expected to be in the dashboard. Some functionality may be
incomplete depending on module, the core Ecommerce modules are priority.

- Advertising
- Advice
- Analytics
- Apps
- Campaign
- Carts
- Collections
- Coupons
- Dashboard
- Discounts
- Email
- Forms
- Insights
- Integrations
- Log
- Native Analytics
- Orders
- Payments
- Planner
- Plans
- Product Recommendations
- Products
- Referrals
- Reporting
- Search
- Segment
- Settings
- Sites
- Social
- Store
- Subscriptions
- Teams
- Transactions
- Users

## Analytics
- Snippets install guide
- Configure integrations
    - Advertising
        - Facebook Pixel
        - Google AdWords Conversions
        - Google Analytics (Enhanced Ecommerce)
        - Adroll
    - Analytics
        - Clicky
        - Mixpanel
        - Heap
        - Kissmetrics
        - Quantcast
        - GoSquared
    - Error and Performance Monitoring
        - Bugsnag
        - Crittercism
        - Sentry
    - Heatmaps and Recording
        - CrazyEgg
        - Full Story
    - Email
        - Marketo
        - Customer.io
    - A/B Testing
        - Optimizely
    - ...And many more

- Native Analytics (Our internal analytics)

- Overview View
    - Orders (Total / %)
    - Revenue (Total / %)
    - Customers (Total / %)
    - Visit (Total / %)
    - Conv (Rate %)
    - AOV (Value / %)
    - Revenue Chart
    - Purchase Funnel

- Visited, Shipped, Added to Cart, Purchased
    - Abandoned Cart
    - Top Products
    - Top Categories
    - Top Visits By Origin
    - Top Referral

- Real Time View
    - Big numbers
    - Statistics
    - Revenue
    - Items Sold
    - Orders
    - Visits
    - Last Products sold
    - Last Activity

- Merchandising View
    - All Categories
        - Products Sold
        - Orders
        - Merch revenue
        - Avg Price
        - Price range
    - Per Product

- Marketing View
    - Visit Origin
    - Origin details
        - Origin, revenue, visits, orders, conv rate, aov, rpv

- Orders View
    - Total Orders
    - Units Solid
    - Revenue
    - Orders Discounted
    - AOV
    - Orders Graph
    - Orders Recent
        - Order #, ordered, subtotal, discounts, shipping, tax total

- Customers View
    - Number
    - New
    - New %
    - Returning %
    - Customers latest
    - Email, name, type, cohort, 1st order, last order

- Purchase Funnel
    - Visited
    - Shopped
    - Added to Cart
    - Purchased
    - Funnel graph

- Abandoned Carts View
    - Abandoned Revenue
    - Abandoned arts
    - Abandon Rate
    - Total Revenue
    - Orders
    - Abandon Rate Chart (Today vs yesterday
    - Abandoned Carts Latest
    - Product, abandoned carts, abandoned revenue, abandon rate, visits

- Abandoned Cart Save Attempts View
    - Saved by automatic email
    - Abandoned vs converted

- In Store Search View
    - Search terms
    - Keywords with results
    - Keywords without results
    - Best performing keywords
    - worst performing keywords
    - Number of searches
    - Most searches in a day
    - average searches per day
    - most popular term with results
    - most popular terms w/o results

- Sales Tax Report
    - Summary of tax collected
    - Period, Tax Type, Tax Rate, Number of orders, Tax Amount

- Would love to embed google analytics, social (fb), twitter, etc as well.

This module additionally provides statistics in other modules:

- Users
- Orders
- Referrals
- Coupons
- Submissions
- Payments
- Subscribers

## Integrations

- Need pages for each to configure (mostly)
- Maybe some sort of grid showing what’s available?

- Custom
- Webhooks
- Hanzo API
- Shop.js link?

- Salesforce

- Payment processors
    - PayPal, Stripe, Affirm, Amazon, etc

- Shipping/Fulfillment
    - Shipstation
    - Shipwire
    - Fulfillrite

- Helpdesks
    - Intercom
    - Zendesk

- Marketing
    - Customer.io
    - Marketo

- Email
    - Mailchimp
    - Mandrill
    - Sendgrid

- Source Control
    - Github
    - Bitbucket
    - Gitlab

- Other
    - Slack
    - Zapier

## Email
- Need to be able to list all email templates
- Need to be able to configure email templates for events

- User Confirmation
- User Confirmed
- User Password Reset
- Account changed
- Order confirmation
- Order shipped

- Promotional emails
    - Coupons
    - Discounts
    - Manual
    - Etc

- Marketing emails might also find their way in here as we start to automate mailing based on events
- Might want designer for that
- Maybe send marketing campaigns via this
- Campaign creator?
- Simple email designer
- Templates
- Preview/Testing
- Default email settings
    - From Name, From Email, Subject, etc

## Forms
- Add forms to your site
- Simple Form creator
- Paste JavaScript snippet (typical use)
- Two types of forms:
    - Submission (contact forms)
    - Subscription (newsletter sign-up)
- Possible to configure to add to different segments/lists in mailchimp, etc.

## Users
- Show a list of interesting users as default view instead of whole list

- Perhaps statistics on users today

- List Users

- Saveable Filters
- Able to preview user in a list by expanding each entry to show user recent history

- Create Users
- Update Users

- Reset Password
- Resent Various Emails
- Add to Segment
- Edit user orders (when orders is enabled)

- Delete Users
- Show user statistics/Story from conversion

- Creation today/month/year
- What ordered
- What viewed
- What in cart/Session data

- Marketing Efforts to a User/Subscriber

- Emails we have sent
- Products they’ve converted on
- Referral Data
- Referrers

- Anonymous visit statistics before sign up

- What did they do
- What did they click on
- Which products were viewed

- Customer Service

- Notes?
- Issue history?

- Geolocation Statistics based on Billing / Order Shipping Address
- Upload from IndieGogo
- Credit System

- Admins need to be able to add and subtract currency from an account via the transactions api

## Payments

- List Payments

- Saveable Filters

- Create Payments
- Refund Payment (Update Order)
- Flag as Fraud/Charge Back etc

## Orders

- Show a list of interesting orders as default view instead of whole list

- Perhaps statistics on orders today

- List Orders

- Saveable Filters

- Create Order
- Update Order

- Change Statuses
- Change Shipping Information
- Send Confirmations and Notifications

- Charge Order Payment
- List Order Payment
- Link to Payment in Integration (Stripe Id, Paypal Paykey, etc)
- Geolocation Statistics based on Order Shipping Address
- Upload from Orders

## Products

- List Products

- Saveable Filters

- Create Product
- Update Product
- Collect Product Status

- How much of each sold, etc

- Add Image Sets
- Add Option Sets

- Customizable List of Images vs Default Select Dropdown

- Create Variants

- Overwrite Product Pricing
- Select corresponding Product Options

- Geolocation Statistics based on Order Shipping Address

## Coupons

- Add coupons, list, edit

- Flat
- Percent
- Free Shipping
- Free Item

- Rule-based coupons
- Shared coupons

- Increase discount based on sharing

- Send coupons

- Based on segment
- Manually

- Visual editor

- Integrate into frontend

- Shareable via social media

- Overlay as you edit the coupon

- Stats

- Number of times coupon is used
- Products sold per coupon (revenue vs discount)
- Referrals

## Store

- List Stores

- Sort by performance?

- Performance Metric like conversion rate?
- Compare Products across stores

- Saveable filter

- Create Stores

- Set Currency

- Update Stores

- Add Product

- Overwrite Default Pricing/Currency

- Add Variant

- Overwrite Default Pricing/Currency

- Disable but not delete stores?

- Need to preserve analytics?

- Upsell people at 5 + stores?

## Referrals

- Design referral programs

- Rules engine for what happens for referrals
- Generate a Coupon?

- Track referral activity
- Visual Editor
- Send an Email/SMS/Share?
- Top Referrers (users)

- Need to identify Brand Influencers
- Tiered Referral Programs



- Stats

- Conversation Rate

- User Viewable

## Settings (Company / Organization)

- Organization Profile

- Full Name
- Country
- Billing Account / Info?

- Plan settings?
- Maybe list active integrations?

- Website
- Phone



- Locations (Tax Nexus)

- Address



- People

- Add People
- Remove/Fire People
- Reset Passwords

- (<span class="c9">[http://vrz.io/ezy3](https://www.google.com/url?q=http://vrz.io/ezy3&sa=D&ust=1457306724280000&usg=AFQjCNE6K65AA4lUkjVYRHZkJQZSAoG0cQ))



- Teams

- List (<span class="c9">[http://vrz.io/ezpx](https://www.google.com/url?q=http://vrz.io/ezpx&sa=D&ust=1457306724281000&usg=AFQjCNF2_fgozZ9XBDY_t128aeYvI2rbVg))

- Edit (<span class="c9">[http://vrz.io/f03G](https://www.google.com/url?q=http://vrz.io/f03G&sa=D&ust=1457306724282000&usg=AFQjCNGI3k2NGgCH1AUQ6YpypwfcHCZkzA))

- Set/Change Permissions

## Apps (A tag associated with a set of API Keys)

- Create
- Regenerate Keys for an app
- Delete
- Tag analytics data with app so we can get analytics data just for an app
- A object that is a name for a set of predefined api keys for working with websites

## Teams

- Create a team
- Invite people to a team
- Set permissions for a team
- Remove people from a team

## Sites

- Add and publish sites

## Log

- Event at a single point in time
- Browse Log
- Add Log from anywhere

## Campaign

- Configure and add campaigns
- List campaigns
- Top performing campaigns
- Comparison with current campaigns
- Analytics

- Duration of time you care about
- Generate newsletter / updates based on milestones

## Carts

- Track history of cart
- Users associated, eventual orders, payments
- Referrals
- Coupons used etc
- Abandoned carts

## Collections

- Organize products
- -Copy from Shopify?

## Discounts

- Discount Rules

## Search

- Snippet (installation guide)

- Search statistics
- Search settings
- Commonly searched terms

## Transactions

- In-store currency
- Edit people’s balance
- Assign credit

## Reporting

- Good Data

## Product Recommendations

## Plans
- Create new plan-type product

## Segment
- Segment Users

## Subscriptions
- Create plans and manage subscription payment plans
- Invoices
- Lets you manage recurring payments
- Metrics
- Conversion Funnel
- Customer Acquisition Costs
- Quota per Sales Rep
- Forecasted Sales
- MRR Movements
- Avg. Deal Size
- Avg. Revenue Per Account
- Annual Run Rate
- Customer Lifetime Value
- COGS
- Gross Margin
- EBITDA
- Customer Churn
- MRR Churn
- Customer Engagement Score
- Net Promoter Score

## Social
- Integrate statistics from Twitter, Facebook, etc
- Recent retweets, etc

## Insights / IQ / Marketing Automation
- Business insights
- Insights View
- Timeline
- Most visited, best converting products
- Worst converters (places to improve)
- Marketing advice (which effort works best)
- See highest value customers
- Send Unique promotional offers
- Identify non-purchasers and offer promotions
- Custom offers to ppl browsing but not buying
- Create pre-populated newsletters
- Detect news for company, recommend new pre-populated newsletter

## Advertising
- View advertising statistics
- Create new ads
- Run experiments
- Similar to adespresso

## Native Analytics
- Enables our native analytics

## Planner
- Guided planner for starting business

## Advice
- Adds help/advice widget?
