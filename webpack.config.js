/* eslint-env node */

const webpack = require('webpack');
const path = require('path');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const BundleAnalyzerPlugin = require('webpack-bundle-analyzer')
    .BundleAnalyzerPlugin;
const HtmlWebpackPlugin = require('html-webpack-plugin');
const InlineManifestWebpackPlugin = require('inline-manifest-webpack-plugin');
const FaviconsWebpackPlugin = require('favicons-webpack-plugin');
const SriPlugin = require('webpack-subresource-integrity');
const CopyPlugin = require('copy-webpack-plugin');

const isBuild = (process.env.npm_lifecycle_event || '').startsWith('build');
const ci = process.env.CI === 'true';
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
            devtoolModuleFilenameTemplate: info =>
                info.resourcePath.replace(/^\.\//, ''),
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
            ...(!isTest
                ? [
                      new HtmlWebpackPlugin({
                          template: 'index.ejs',
                          prod: prod,
                          minify: htmlMinDefaults,
                      }),
                  ]
                : []),
            ...(isBuild
                ? [
                      new webpack.NamedModulesPlugin(),
                      new InlineManifestWebpackPlugin({
                          name: 'webpackManifest',
                      }),
                      new FaviconsWebpackPlugin(
                          './app/assets/images/favicon.png',
                      ),
                      new SriPlugin({
                          hashFuncNames: ['sha512'],
                      }),
                      new CopyPlugin([
                          { from: 'src/.well-known', to: '.well-known' },
                      ]),
                  ]
                : []),
            ...(env.analyze ? [new BundleAnalyzerPlugin()] : []),
        ],
        module: {
            rules: [
                {
                    test: /\.js$/,
                    exclude: /node_modules/,
                    use: [
                        {
                            loader: 'babel-loader',
                            options: {
                                plugins: [
                                    '@babel/plugin-transform-runtime',
                                    '@babel/plugin-syntax-dynamic-import',
                                    '@babel/plugin-transform-template-literals',
                                    ...(!isTest ? ['angularjs-annotate'] : []),
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
                    test: /\.js$/,
                    exclude: /node_modules/,
                    loader: 'eslint-loader',
                    enforce: 'pre',
                    options: {
                        // Show errors as warnings during development to prevent start/test commands from exiting
                        failOnError: isBuild || ci,
                        emitWarning: !isBuild && !ci,
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
