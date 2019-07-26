import React from 'react';
import gql from 'graphql-tag';

import { renderWithContext } from '../../../testUtils';
import StagesSummary from '../';

const QUERY = gql`
    query communityReport {
        communityReport {
            communityStagesReport {
                pathwayStage
                personalStepsCompletedCount
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
                    data.communityReport.communityStagesReport.map(entry => ({
                        stage: entry.pathwayStage,
                        icon: entry.pathwayStage
                            .toLowerCase()
                            .replace(' ', '-'),
                        count: entry.otherStepsCompletedCount,
                    }))
                }
            />,
        ).snapshot();
    });

    // TODO: Add a test with mocking data when GraphQL schema contains above query
});
