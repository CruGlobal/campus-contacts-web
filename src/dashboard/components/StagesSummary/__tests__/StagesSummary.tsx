import React from 'react';
import gql from 'graphql-tag';

import { renderWithContext } from '../../../testUtils';
import StagesSummary from '../';

const QUERY = gql`
    query communityReport(
        $period: String!
        $id: ID!
        $endDate: ISO8601DateTime!
    ) {
        community(id: $id) {
            report(period: $period, endDate: $endDate) {
                stagesReport {
                    stage {
                        name
                    }
                    personalStepsCompletedCount
                }
            }
        }
    }
`;

describe('<StagesSummary />', () => {
    it('should render properly', async () => {
        renderWithContext(
            <StagesSummary
                query={QUERY}
                variables={{
                    organizationId: 1,
                }}
                mapData={data =>
                    data.community.report.stagesReport.map((entry: any) => ({
                        stage: entry.stage.name,
                        icon: entry.stage.name.toLowerCase().replace(' ', '-'),
                        count: entry.personalStepsCompletedCount,
                    }))
                }
            />,
        ).snapshot();
    });

    // TODO: Add a test with mocking data when GraphQL schema contains above query
});
