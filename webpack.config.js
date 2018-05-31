/* eslint-env node */

const webpack = require('webpack');
const path = require('path');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;
const HtmlWebpackPlugin = require('html-webpack-plugin');
const InlineManifestWebpackPlugin = require('inline-manifest-webpack-plugin');
const ManifestPlugin = require('webpack-manifest-plugin');
const FaviconsWebpackPlugin = require('favicons-webpack-plugin');
const SriPlugin = require('webpack-subresource-integrity');

const isBuild = (process.env.npm_lifecycle_event || '').startsWith('build');
const ci = process.env.CI === 'true';
const prod = process.env.TRAVIS_BRANCH === 'master';
let publicPath;
switch (process.env.TRAVIS_BRANCH) {
    case undefined:
        publicPath = 'http://localhost:8080/';
        break;
    case 'staging':
        publicPath = 'https://d17qkzkfpa9gxm.cloudfront.net/';
        break;
    case 'master':
        publicPath = 'https://d3n8lspvao4e66.cloudfront.net/';
        break;
}

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
    removeStyleTypeAttributes: true
};

module.exports = (env = {}) => {
    const isTest = env.test;
    return {
        mode: isBuild ? 'production' : 'development',
        entry: {
            app: './src/main.ts'
        },
        output: {
            filename: '[name].[chunkhash].js',
            chunkFilename: '[name].[chunkhash].js',
            path: path.resolve(__dirname, 'dist'),
            publicPath: publicPath,
            devtoolModuleFilenameTemplate: info => info.resourcePath.replace(/^\.\//, ''),
            crossOriginLoading: 'anonymous'
        },
        optimization: {
            splitChunks: {
                cacheGroups: {
                    commons: {
                        test: /[\\/]node_modules[\\/]/,
                        name: 'vendor',
                        chunks: 'initial'
                    }
                }
            }
        },
        plugins: [
            new MiniCssExtractPlugin({
                filename: '[name].[contenthash].css'
            }),
            new ManifestPlugin(),
            ...!isTest ? [
                new HtmlWebpackPlugin({
                    template: 'index.ejs',
                    prod: prod,
                    minify: htmlMinDefaults
                }),
            ] : [],
            ...isBuild ?
                [
                    new webpack.NamedModulesPlugin(),
                    new InlineManifestWebpackPlugin({
                        name: 'webpackManifest'
                    }),
                    new FaviconsWebpackPlugin('./app/assets/images/favicon.png'),
                    new SriPlugin({
                        hashFuncNames: ['sha512']
                    })
                ] : [],
            ...env.analyze ? [ new BundleAnalyzerPlugin() ] : []
        ],
        module: {
            rules: [
                {
                    test: /\.tsx?$/,
                    use: ['ts-loader', 'angular2-template-loader'],
                    exclude: /node_modules/
                },
                {
                    test: /\.js$/,
                    exclude: /node_modules/,
                    use: [
                        {
                            loader: 'babel-loader',
                            options: {
                                presets: [['env', { modules: false }]],
                                plugins: [
                                    'transform-runtime',
                                    'syntax-dynamic-import',
                                    ...!isTest ? ['angularjs-annotate'] : []
                                ]
                            }
                        }
                    ]
                },
                {
                    test: /\.html$/,
                    use: ['html-loader']
                },
                {
                    test: /\.js$/,
                    exclude: /node_modules/,
                    loader: 'eslint-loader',
                    enforce: 'pre',
                    options: {
                        // Show errors as warnings during development to prevent start/test commands from exiting
                        failOnError: isBuild || ci,
                        emitWarning: !isBuild && !ci
                    }
                },
                {
                    test: /\.(scss|css)$/,
                    use: [
                        MiniCssExtractPlugin.loader,
                        {
                            loader: 'css-loader',
                            options: {
                                sourceMap: true
                            }
                        },
                        {
                            loader: 'sass-loader',
                            options: {
                                sourceMap: true
                            }
                        }
                    ]
                },
                {
                    test: /\.(woff|ttf|eot|ico)/,
                    use: [{
                        loader: 'file-loader',
                        options: {
                            name: '[name].[hash].[ext]'
                        }
                    }]
                },
                {
                    test: /\.(svg|png|jpe?g|gif)/,
                    use: [
                        {
                            loader: 'file-loader',
                            options: {
                                name: '[name].[hash].[ext]'
                            }
                        },
                        {
                            loader: 'image-webpack-loader',
                            options: {}
                        }
                    ]
                }
            ]
        },
        resolve: {
            // modules: [path.resolve(__dirname, 'app'), 'node_modules'],
            extensions: [ '.tsx', '.ts', '.js', '.json' ]
        },
        devtool: 'source-map',
        devServer: {
            historyApiFallback: true,
            headers: {
                'Access-Control-Allow-Origin': '*'
            }
        }
    };
};
