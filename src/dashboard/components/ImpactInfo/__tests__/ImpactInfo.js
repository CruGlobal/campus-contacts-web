import React from 'react';
import gql from 'graphql-tag';
import { waitForElement } from '@testing-library/react';

import { renderWithContext } from '../../../testUtils';
import ImpactInfo from '../';

const QUERY = gql`
    query impactReport($organizationId: ID!) {
        impactReport(organizationId: $organizationId) {
            pathwayMovedCount
        }
    }
`;

describe('<ImpactInfo />', () => {
    it('should render properly loading state', async () => {
        renderWithContext(
            <ImpactInfo
                query={QUERY}
                text={report =>
                    `Text with value ${report.impactReport.pathwayMovedCount}`
                }
                variables={{ organizationId: 1 }}
            />,
            {
                appContext: {
                    orgId: 1,
                },
            },
        ).snapshot();
    });

    it('should render properly with data', async () => {
        const { snapshot, getByText } = renderWithContext(
            <ImpactInfo
                query={QUERY}
                text={report =>
                    `Text with value ${report.impactReport.pathwayMovedCount}`
                }
                variables={{ organizationId: 1 }}
            />,
            {
                mocks: {
                    Query: () => ({
                        impactReport: () => ({
                            pathwayMovedCount: () => 15,
                        }),
                    }),
                },
                appContext: {
                    orgId: 1,
                },
            },
        );

        await waitForElement(() =>
            getByText('Text with value', { exact: false }),
        );
        snapshot();
    });
});
