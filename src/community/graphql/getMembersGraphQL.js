import gql from 'graphql-tag';

export const GET_MEMBERS_GRAPHQL = gql`
    query {
        organization(id: 2) {
            id
            stage_0: stageReport(pathwayStageId: 6) {
                memberCount
                id
                pathwayStage {
                    name
                    description
                }
            }
            stage_1: stageReport(pathwayStageId: 1) {
                memberCount
                id
                pathwayStage {
                    name
                    description
                }
            }
            stage_2: stageReport(pathwayStageId: 2) {
                memberCount
                id
                pathwayStage {
                    name
                    description
                }
            }
            stage_3: stageReport(pathwayStageId: 3) {
                memberCount
                id
                pathwayStage {
                    name
                    description
                }
            }
            stage_4: stageReport(pathwayStageId: 4) {
                memberCount
                id
                pathwayStage {
                    name
                    description
                }
            }
            stage_5: stageReport(pathwayStageId: 5) {
                memberCount
                id
                pathwayStage {
                    name
                    description
                }
            }
        }
    }
`;
