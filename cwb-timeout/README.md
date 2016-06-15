# cwb-timeout

Installs the `cwb-timeout` benchmark and provides utilities to integrate with Cloud WorkBench.

## Attributes

See `attributes/default.rb`

## Usage

### Cloud WorkBench

| Metric Name                  | Unit              | Scale Type    |
| ---------------------------- | ----------------- | ------------- |
| **metric-name**              | unit              | ratio/nominal |
| cpu                          | model-name        | nominal       |

**bold-written** metrics are mandatory

### cwb-timeout::default

Add the `cwb-timeout` default recipe to your Chef configuration in the Vagrantfile:

```ruby
config.vm.provision 'cwb', type: 'chef_client' do |chef|
  chef.add_recipe 'cwb-timeout@0.1.0'  # Version is optional
  chef.json =
  {
    'cwb-timeout' => {
        'metric_name' => 'execution_time',
    },
  }
end
```

## License and Authors

Author:: YOUR_NAME (<YOUR_EMAIL>)
