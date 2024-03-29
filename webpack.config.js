/* eslint-env node */

const path = require('path');

const webpack = require('webpack');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;
const HtmlWebpackPlugin = require('html-webpack-plugin');
const FaviconsWebpackPlugin = require('favicons-webpack-plugin');
const SriPlugin = require('webpack-subresource-integrity');
const CopyPlugin = require('copy-webpack-plugin');
const WorkboxPlugin = require('workbox-webpack-plugin');

const isBuild = (process.env.npm_lifecycle_event || '').startsWith('build');
const prod = process.env.TRAVIS_BRANCH === 'master';

const htmlMinDefaults = {
  removeComments: true,
  removeCommentsFromCDATA: true,
  removeCDATASectionsFromCDATA: true,
  collapseWhitespace: true,
  conservativeCollapse: true,
  removeAttributeQuotes: true,
  useShortDoctype: true,
  keepClosingSlash: true,
  minifyJS: true,
  minifyCSS: true,
  removeScriptTypeAttributes: true,
  removeStyleTypeAttributes: true,
};

module.exports = (env = {}) => {
  const isTest = env.test;
  return {
    mode: isBuild ? 'production' : 'development',
    entry: {
      app: 'assets/javascripts/angular/main.js',
    },
    output: {
      filename: '[name].[chunkhash].js',
      chunkFilename: '[name].[chunkhash].js',
      path: path.resolve(__dirname, 'dist'),
      devtoolModuleFilenameTemplate: (info) => info.resourcePath.replace(/^\.\//, ''),
      crossOriginLoading: 'anonymous',
    },
    optimization: {
      splitChunks: {
        cacheGroups: {
          commons: {
            test: /[\\/]node_modules[\\/]/,
            name: 'vendor',
            chunks: 'initial',
          },
        },
      },
    },
    plugins: [
      new MiniCssExtractPlugin({
        filename: '[name].[contenthash].css',
      }),
      ...(isTest
        ? []
        : [
            new HtmlWebpackPlugin({
              template: 'index.ejs',
              prod,
              minify: htmlMinDefaults,
            }),
          ]),
      ...(isBuild
        ? [
            new webpack.NamedModulesPlugin(),
            new FaviconsWebpackPlugin({
              logo: './app/assets/images/favicon.svg',
              favicons: {
                appName: 'Campus Contacts',
                developerName: 'Cru',
                theme_color: '#007398',
                background: '#FFFFFF',
                icons: {
                  appleIcon: { offset: 10 }, // Create Apple touch icons. `boolean` or `{ offset, background, mask, overlayGlow, overlayShadow }`
                  appleStartup: { offset: 10 }, // Create Apple startup images. `boolean` or `{ offset, background, mask, overlayGlow, overlayShadow }`
                  coast: { offset: 10 }, // Create Opera Coast icon. `boolean` or `{ offset, background, mask, overlayGlow, overlayShadow }`
                  windows: { offset: 10 }, // Create Windows 8 tile icons. `boolean` or `{ offset, background, mask, overlayGlow, overlayShadow }`
                },
              },
            }),
            new SriPlugin({
              hashFuncNames: ['sha512'],
            }),
            new CopyPlugin({
              patterns: [
                {
                  from: 'app/assets/images/campuscontacts-the-key-logo.svg',
                },
              ],
            }),
            new WorkboxPlugin.GenerateSW({
              clientsClaim: true,
              skipWaiting: true,
            }),
          ]
        : []),
      ...(env.analyze ? [new BundleAnalyzerPlugin()] : []),
    ],
    module: {
      rules: [
        {
          test: /\.(ts|js)x?$/,
          exclude: /node_modules/,
          use: [
            {
              loader: 'babel-loader',
              options: {
                plugins: [
                  '@babel/plugin-transform-runtime',
                  '@babel/plugin-syntax-dynamic-import',
                  '@babel/plugin-transform-template-literals',
                  ...(isTest ? [] : ['angularjs-annotate']),
                ],
              },
            },
          ],
        },
        {
          test: /\.html$/,
          use: ['html-loader'],
        },
        {
          test: /\.(ts|js)x?$/,
          exclude: /node_modules/,
          loader: 'eslint-loader',
          enforce: 'pre',
          options: {
            // Show errors as warnings to prevent webpack from exiting
            failOnError: false,
            emitWarning: true,
          },
        },
        {
          test: /\.(scss|css)$/,
          use: [
            MiniCssExtractPlugin.loader,
            {
              loader: 'css-loader',
              options: {
                sourceMap: true,
              },
            },
            {
              loader: 'sass-loader',
              options: {
                sourceMap: true,
                sassOptions: {
                  quietDeps: true,
                },
              },
            },
          ],
        },
        {
          test: /\.(woff|ttf|eot|ico)/,
          use: [
            {
              loader: 'file-loader',
              options: {
                name: '[name].[hash].[ext]',
              },
            },
          ],
        },
        {
          test: /\.(svg|png|jpe?g|gif)/,
          use: [
            {
              loader: 'file-loader',
              options: {
                name: '[name].[hash].[ext]',
              },
            },
            {
              loader: 'image-webpack-loader',
              options: {},
            },
          ],
        },
      ],
    },
    resolve: {
      modules: [path.resolve(__dirname, 'app'), 'node_modules'],
      extensions: ['.mjs', '.ts', '.tsx', '.js', '.jsx'],
    },
    devtool: 'source-map',
    devServer: {
      historyApiFallback: true,
      https: true,
      headers: {
        'Access-Control-Allow-Origin': '*',
      },
    },
  };
};
