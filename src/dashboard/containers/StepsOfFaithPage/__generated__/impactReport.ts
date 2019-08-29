/* tslint:disable */
/* eslint-disable */
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: impactReport
// ====================================================

export interface impactReport_community_impactReport {
    __typename: 'ImpactReport';
    /**
     * Count of stage progression steps for members
     */
    membersStageProgressionCount: number;
}

export interface impactReport_community {
    __typename: 'Community';
    impactReport: impactReport_community_impactReport;
}

export interface impactReport {
    /**
     * Find a community by ID
     */
    community: impactReport_community;
}

export interface impactReportVariables {
    id: string;
}
