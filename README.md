***Important***

***For the reason of fir.im had changed the Base URL, pls set `firim_api_url` to `https://fir-api.fircli.cn/` or `https://api.bq04.com`.*** [issue](https://github.com/whlsxl/firim/issues/26)

From v0.2.5, the default `firim_api_url` set to `https://api.bq04.com`.

From firim v0.2.6, add show download url in terminal. [issue](https://github.com/whlsxl/firim/issues/32)
# Firim

Firim is a command tool to directly upload ipa and change app infomation on fir.im. fir.im is a Beta APP host website, you can upload ipa for AdHoc or InHouse distribution for testing.

## Getting Started

Add this line to your application's Gemfile:

```ruby
gem 'firim'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install firim

## Quick Start

* `cd [your_project_folder]`
* `firim init`
* Enter your fir.im API Token (From [Fir.im](https://fir.im/apps))
* `firim -i [your_ipa_path]`

# Usage

Use with fastlane [fastlane-plugin-firim](fastlane-plugin-firim/)

You can specify the app infomations in `Firimfile`, To get a list of available options run

    firim --help

Upload with icon ***NOTICE: Icon must be jpg format***

    firim -i [your_ipa_path] -l [your_icon_path]
    
Use `firim_api_url` to set API URL, if `fir.im` change the Base URL. default is `https://api.fir.im`.

After upload app to fir.im, firim will export some environment variables.

* `FIRIM_APP_SHORT` app's short path
* `FIRIM_APP_NAME` app's name
* `FIRIM_APP_URL` the download page of the app

# Assign API Token

There are three ways to assign Firim API Token

1. Set `FIRIM_TOKEN` environment variables
2. Add `token` to `macOS Keychain`
3. Set in `Firimfile`

`Firim` will check the value from 1 to 3. Run `Firim` will add `token` to `keychain` in interactive shell. Also can use `firim addtoken` and `firim removetoken` to add or remove `token`.


# Need help?

Please submit an issue on GitHub and provide information about your setup


## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/whlsxl/firim](https://github.com/whlsxl/firim). This project is intended to be a safe, welcoming space for collaboration.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

# TODO

- [ ]  Generate a web page show all the app's link and infomations
- [x]  Show the app list, and export all app infomations to a file
- [ ]  force reset icon
