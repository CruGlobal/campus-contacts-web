import React from 'react';
import { Provider } from 'react-redux';
import { Playground, store } from 'graphql-playground-react';
import { Global, css } from '@emotion/core';

export interface GraphqlPlaygroundProps {
    authenticationService: any;
    envService: any;
}

const GraphqlPlayground = ({
    authenticationService,
    envService,
}: GraphqlPlaygroundProps) => {
    const token = authenticationService.isTokenValid();
    const config = {
        extensions: {
            endpoints: {
                [envService.get()]: {
                    url: `${envService
                        .read('apiUrl')
                        .replace('/v4', '')}/graphql`,
                    headers: {
                        Authorization: `Bearer ${token || 'none'}`,
                    },
                },
            },
        },
    };
    return (
        <>
            <Global
                styles={css`
                    @import url('https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700|Source+Code+Pro:400,700');
                    body {
                        overflow: hidden;
                    }
                `}
            />
            <Provider store={store as any}>
                <Playground config={config} />
            </Provider>
        </>
    );
};

export default GraphqlPlayground;
