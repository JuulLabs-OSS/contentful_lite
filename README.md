# contentful-lite

![Rspec](https://github.com/JuulLabs/contentful-lite/workflows/Rspec/badge.svg?branch=master&event=push)

> Ruby SDK gem for retrieving content from Contentful Content Delivery API and Content Preview API. A lighter replacement for the official contentful gem.

### But why?
We've been using the official contentful gem for a while and we discovered it was causing a big memory leak. Among other issues, the main problem was that on the official gem the serialization of entries for cache stores a lot of extra information that we didn't require, causing to spend more cache memory unnecessarily. So we decided to build a custom lite gem providing support only for the features we were using.

## Features
- Retrieve entries and assets from CDA and CPA
- Localization support
- Modeling of Content Types into Ruby classes
- Cache serialization
- Content validations using ActiveModel::Validations
- Retrieve data from any environment
- Pagination data

## Getting Started

#### Installation
Add to your Gemfile:

`gem 'contentful-lite', git: "https://github.com/JuulLabs/contentful-lite.git"`

#### Use it!
```ruby
  require 'contentful_lite'

  # First create the client by providing  your space id and access token.
  # You can also add environment: 'any_env' or preview: true if you prefer to use CPA
  client = ContentfulLite::Client.new(space_id: 'cfexampleapi', access_token: 'b4c0n73n7fu1')
  # Then request the entries
  client.entries
```

## Creating your model classes with macros

This gem was created for being able to subclass the `ContentfulLite::Entry` and provide custom methods for each of the content models that you create on your contentful space.

This customization is really easy to implement. An example of a complete model may look like this:

```ruby
  class ContentPage < ContentfulLite::Entry
    content_type_id 'content_page'

    field_reader :title, :open_graph_image
    field_reader :layout, default: 'simple'
    field_reader :sections, default: []

    validates :title, presence: true
    validates_included_entry :sections, array: true
    validates_included_asset :open_graph_image, type: 'image'
  end
```

### Simple step by step explanation

1. Create a class and inherit from `ContentfulLite::Entry`
2. Call `content_type_id` to set the mapping to the right contentful content model.
3. Call `field_reader` macro to setup your field accessors.
4. Define your validations

### Reference for field accessors macros

- #### field_reader

  This macro define accessors methods for one or many fields.

  **Parameters:**

  - `*attrs` A symbol or array of symbols with the fields name you want to define.
  - `default: nil` The default value in case there is no value for that field.
  - `localizable: false` A boolean to indicate if this field is marked as localizable on contentful. If true, calling `#field_name(locale: custom)` will try to retrieve the value for that locale. If false, the same call will ignore the provided locale and instead use the main locale for the entry.

### Reference for validations macros

Validations are implemented using ActiveModel::Validations so all the active model validation methods can be used, but you can also call our custom validation macros for contentful entries.

- #### validates\_included\_entry

  Adds a validation for attributes with referenced entries.

  **Parameters:**

  - `*attr_names` A symbol or array of symbols with the fields name you want to include in this validation.
  - `allow_blank: false` Optional boolean to determine if the validation should pass when the field is blank.
  - `array: false` Optional boolean to determine if the field should be a single entry or an array of entries.
  - `allowed_models: nil` Optional array of ruby subclasses of `ContentfulLite::Entry` with the allowed models to be referenced by this field. If not provided, any class will be allowed.

- #### validates\_included\_asset

  Adds a validation for attributes with referenced assets.

  **Parameters:**

  - `*attr_names` A symbol or array of symbols with the fields name you want to include in this validation.
  - `allow_blank: false` Boolean to determine if the validation should pass when the field is blank.
  - `array: false` Boolean to determine if the field should be a single asset or an array of assets.
  - `type: nil` String for validate it's appearance inside the file's content type. If not provided, the content type check will be omitted.

## Public Methods Reference

### ContentfulLite::Client
- #### #initialize `client = ContentfulLite::Client.new`

  Builds the client for being able to retrieve data.

   **Parameters:**
   - `space_id:` Mandatory, you need to include the space_id you want to retrieve content from
   - `access_token:` Mandatory, provide an access token for that space. You can read more about access tokens on [Contentful Documentation for CDA Authentication](https://www.contentful.com/developers/docs/references/content-delivery-api/#/introduction/authentication)
   - `environment: nil` Optional. If you want to retrieve the content from an environment that is not the default on contentful, you can include the environment name here.
   - `preview: false` Optional. True for using Content Preview API, otherwise it will use Content Delivery API.


- #### #entries `client.entries(query = {})`

  Searches for all the entries that fulfills the query conditions and returns an array (`ContentfulLite::EntriesArray`) with all the retrieved entries, using the right subclass of `ContentfulLite::Entry` (according to the entry mapping) for each of the entries.

  **Parameters:**
  - `query: {}` Optional, a hash representing any parameter you want to include in your CDA/CPA query. Read about search parameters on the [Contentful Documentation for Search Parameters](https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/search-parameters)


- #### #entry `client.entry(id, query = {})`
  Retrieves a single entry by id and returns an object of the right subclass of `ContentfulLite::Entry` according to the entry mapping.

  **Parameters:**
  - `id` Mandatory, the id for the entry you want to retrieve.
  - `query = {}` Optional, a hash representing any parameter you want to include in your CDA/CPA query. Read about search parameters on the [Contentful Documentation for Search Parameters](https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/search-parameters). Note that this API call doesn't allow the `include` parameter.


- #### #assets `client.assets(query = {})`

  Searches for all the assets that fulfills the query conditions and returns an array (`ContentfulLite::AssetsArray`) with all the requested assets

  **Parameters:**
  - `query: {}` Optional, a hash representing any parameter you want to include in your CDA/CPA query. Read about search parameters on the [Contentful Documentation for Search Parameters](https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/search-parameters)

- #### #asset `client.asset(id, query = {})`

  Retrieves a single asset by id and returns a `ContentfulLite::Asset`

  **Parameters:**
  - `id` Mandatory, the id for the asset you want to retrieve.
  - `query = {}` Optional, a hash representing any parameter you want to include in your CDA/CPA query. Read about search parameters on the [Contentful Documentation for Search Parameters](https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/search-parameters).


- #### #build\_resource `client.build_resource(raw)`

  Used for webhooks, it receives a raw body from the webhook callback and returns the right object according to the `sys.type`.

  **Parameters:**
  - `raw` Mandatory, the raw JSON received from the webhook callback.

### ContentfulLite::Entry
- #### #contentful\_link `entry.contentful_link`

  Returns the link to edit the entry on the contentful webapp.

- #### #fields `entry.fields(locale: nil)`

  Provided a hash with all the fields on the specified locale

  **Parameters:**
  - `locale: nil` Optional, the locale code for the fields you want to retrieve. Defaults to first received locale

- #### #valid? `entry.valid?(locale: nil)`

  Executes the validations for the specified locale.

  **Parameters:**
  - `locale: nil` Optional, the locale code you want to validate. Defaults to first received locale

    Reference to #valid? [Active Model Documentation](https://api.rubyonrails.org/v5.2.3/classes/ActiveModel/Validations.html) for more information about this method.

- #### #errors `entry.errors(locale: nil)`

  Provides a ActiveModel::Errors with all the errors for the specified locale. You need to call it after `#valid?`

  **Parameters:**
  - `locale: nil` Optional, the locale code for the errors you want to retrieve. Defaults to first received locale

    Reference to #errors [Active Model Documentation](https://api.rubyonrails.org/v5.2.3/classes/ActiveModel/Validations.html) for more information about this method.


- #### #valid\_for\_all\_locales? `entry.valid_for_all_locales?`

  Runs `#valid?` for each locale in the entry.

- #### #errors\_for\_all\_locales `entry.errors_for_all_locales`

  Returns an array of `locale => ActiveModel::Errors`

- #### fields accessors `entry.field_name(locale: nil)`

  Field accessors are defined using the `field_reader` macro. They receive and optional locale as parameter and returns the value for that field in the provided locale. Using the macro as `field_reader :content_field` will provide a `entry.content_field(locale: nil)` method.

  **Parameters:**
  - `locale: nil` Optional, the locale code for the field you want to retrieve. Defaults to first received locale

- #### sys accessors

  ```
  #id, #created_at, #updated_at, #locale,
  #revision, #space_id, #environment_id,
  #retrieved_at, #locales
  ```
  Provides access to the system data for the entry


### ContentfulLite::Asset

- #### #contentful\_link `asset.contentful_link`

  Returns the link to edit the asset on the contentful webapp.

- #### sys accessors

  ```
  #id, #created_at, #updated_at, #locale,
  #revision, #space_id, #environment_id,
  #retrieved_at, #locales
  ```
  Provides access to the system data for the entry

- #### asset accessors
  ```
  #title(locale: nil), #description(locale: nil),
  #file_name(locale: nil), #content_type(locale: nil)
  #url(locale: nil), file_details(locale: nil)
  ```
  Provides access to the asset data in the requested locale.

  **Parameters:**
  - `locale: nil` Optional, the locale code for the fields you want to retrieve. Defaults to first received locale

### ContentfulLite::AssetsArray and ContentfulLite::EntriesArray

These classes inherits all methods from ruby Array class, but also implements the support for pagination data.

- #### #total `array.total`

  Returns the total number of resources (entries or assets) for the request that created the array.

- #### #skip `array.skip`

  Returns the number of skipped resources (entries or assets) for the request that created the array.

- #### #limit `array.limit`

  Returns the maximum number of resources returned (entries or assets) for the request that created the array.

## Development

### Git Hooks

  To Alias git hooks locally run `git config core.hooksPath git_hooks` inside the project.
