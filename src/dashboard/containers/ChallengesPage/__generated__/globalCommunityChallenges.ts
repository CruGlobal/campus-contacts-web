/* tslint:disable */
/* eslint-disable */
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: globalCommunityChallenges
// ====================================================

export interface globalCommunityChallenges_community_communityChallenges_nodes {
    __typename: 'CommunityChallenge';
    id: string;
    title: string;
    acceptedCount: number;
    completedCount: number;
    createdAt: any;
    endDate: string;
}

export interface globalCommunityChallenges_community_communityChallenges_pageInfo {
    __typename: 'PageInfo';
    /**
     * When paginating forwards, are there more items?
     */
    hasNextPage: boolean;
    /**
     * When paginating backwards, the cursor to continue.
     */
    startCursor: string | null;
    /**
     * When paginating forwards, the cursor to continue.
     */
    endCursor: string | null;
    /**
     * When paginating backwards, are there more items?
     */
    hasPreviousPage: boolean;
}

export interface globalCommunityChallenges_community_communityChallenges {
    __typename: 'CommunityChallengeConnection';
    /**
     * A list of nodes.
     */
    nodes: globalCommunityChallenges_community_communityChallenges_nodes[];
    /**
     * Information to aid in pagination.
     */
    pageInfo: globalCommunityChallenges_community_communityChallenges_pageInfo;
}

export interface globalCommunityChallenges_community {
    __typename: 'Community';
    communityChallenges: globalCommunityChallenges_community_communityChallenges;
}

export interface globalCommunityChallenges {
    /**
     * Find a community by ID
     */
    community: globalCommunityChallenges_community;
}

export interface globalCommunityChallengesVariables {
    id: string;
    first?: number | null;
    after?: string | null;
}
