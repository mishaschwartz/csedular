const { environment } = require('@rails/webpacker')
const erb = require('./loaders/erb')
const webpack = require('webpack');

environment.plugins.prepend('ProvidePlugin-JQuery',
  new webpack.ProvidePlugin({
    $: 'jquery/src/jquery',
    jQuery: 'jquery/src/jquery'
  })
);

const nodeModulesLoader = environment.loaders.get('nodeModules');
if (!Array.isArray(nodeModulesLoader.exclude)) {
  nodeModulesLoader.exclude = nodeModulesLoader.exclude == null ? [] : [nodeModulesLoader.exclude];
}

// exclude react-table (see: https://github.com/tannerlinsley/react-table/discussions/2048)
nodeModulesLoader.exclude.push(/react-table/);

environment.loaders.prepend('erb', erb)
module.exports = environment;
