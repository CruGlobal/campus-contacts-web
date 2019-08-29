/* tslint:disable */
/* eslint-disable */
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: communityDayReport
// ====================================================

export interface communityDayReport_community_report_daysReport_stageResults_stage {
    __typename: 'Stage';
    name: string;
}

export interface communityDayReport_community_report_daysReport_stageResults {
    __typename: 'StageDayResult';
    othersStepsCompletedCount: number;
    stage: communityDayReport_community_report_daysReport_stageResults_stage;
}

export interface communityDayReport_community_report_daysReport {
    __typename: 'CommunityDayReport';
    date: string;
    /**
     * Count of completed steps taken with people other than the creator
     */
    othersStepsCompletedCount: number | null;
    stageResults: communityDayReport_community_report_daysReport_stageResults[];
}

export interface communityDayReport_community_report {
    __typename: 'CommunitiesReport';
    /**
     * Community Days Report: Day based stats report for steps and interactions completed daily.
     */
    daysReport: communityDayReport_community_report_daysReport[];
}

export interface communityDayReport_community {
    __typename: 'Community';
    /**
     * Get a report of interactions, contact statuses, and contact stages in communities
     */
    report: communityDayReport_community_report;
}

export interface communityDayReport {
    /**
     * Find a community by ID
     */
    community: communityDayReport_community;
}

export interface communityDayReportVariables {
    period: string;
    id: string;
    endDate: any;
}
