/* tslint:disable */
/* eslint-disable */
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: communityStagesReport
// ====================================================

export interface communityStagesReport_community_report_stagesReport_stage {
    __typename: 'Stage';
    name: string;
}

export interface communityStagesReport_community_report_stagesReport {
    __typename: 'CommunityStageReport';
    /**
     * Total number of contacts (non-members) at this stage
     */
    contactCount: number;
    stage: communityStagesReport_community_report_stagesReport_stage;
}

export interface communityStagesReport_community_report {
    __typename: 'CommunitiesReport';
    /**
     * Community Stages Report
     */
    stagesReport: communityStagesReport_community_report_stagesReport[];
}

export interface communityStagesReport_community {
    __typename: 'Community';
    /**
     * Get a report of interactions, contact statuses, and contact stages in communities
     */
    report: communityStagesReport_community_report;
}

export interface communityStagesReport {
    /**
     * Find a community by ID
     */
    community: communityStagesReport_community;
}

export interface communityStagesReportVariables {
    period: string;
    id: string;
    endDate: any;
}
