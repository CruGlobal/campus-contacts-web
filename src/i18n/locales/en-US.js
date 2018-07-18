export default {
    common: {
        became_curious: 'Became curious',
        became_open_to_change: 'Became open to change',
        engaged_disciple: 'Engaged Disciple',
        growing_disciple: 'Growing disciple',
        involved: 'Involved',
        knows_and_trusts_christian: 'Knows and trusts a Christian',
        made_decision: 'Made a decision',
        ministering_disciple: 'Ministering disciple',
        multiplying_disciple: 'Multiplying disciple',
        seeker: 'Seeker',
        seeking_god: 'Seeking God',
        address_types: {
            current: 'Current',
            emergency1: 'Emergency 1',
            emergency2: 'Emergency 2',
            permanent: 'Permanent',
        },
        application: {
            add_contact: {
                title_permission: 'Permissions',
            },
            assign_search: {
                me: 'Me',
                placeholder: "Type a person's name you want to assign to here",
            },
            interaction_types: {
                comment: 'Comment Only',
                discipleship: 'Discipleship Conversation',
                gospel_presentation: 'Personal Evangelism',
                graduating_on_mission: 'Graduating on Mission',
                holy_spirit_presentation: 'Holy Spirit Presentation',
                prayed_to_receive_christ: 'Personal Evangelism Decisions',
                spiritual_conversation: 'Spiritual Conversation',
            },
        },
        assignments: {
            assigned: 'Assigned',
            assignment: 'Assigned to',
            unassigned: 'Unassigned',
        },
        beta: {
            welcome: {
                accept: "Let's Go!",
                no_thanks: 'No Thanks',
                p1:
                    'We are excited about the improved navigation and performance. We hope you enjoy it, too!',
                p2:
                    'If you need any help, click the life ring in the bottom right!',
                title: 'Welcome to the new MissionHub!',
                try: 'Try Beta',
            },
        },
        contact: {
            add: 'Add',
            assigned_to: 'Assigned To',
            cru_status: 'Role',
            delete: 'Delete',
            edit: 'Edit',
            email_address: 'Email',
            first_name: 'First',
            followup_status: 'Status',
            gender: 'Gender',
            last_name: 'Last',
            phone_number: 'Phone',
            primary_email: 'Primary',
            primary_phone: 'Primary',
            student_status: 'Enrollment',
        },
        contacts: {
            add_contact: 'Add Contact',
            all_contacts: {
                title: 'All Contacts',
            },
            index: {
                filter: 'Search',
                for_this_permission_email_is_required:
                    "Email is required for '{{permission}}' permission.",
                for_this_permission_email_is_required_no_name:
                    'Email is required for this permission.',
                import_contacts: 'Import Contacts',
                search_contact_results_description:
                    'Please use the form to find a contact.',
                search_locate_contact_button: 'Go find',
                unassigned: 'Unassigned',
            },
            statuses: {
                uncontacted: 'Uncontacted',
            },
        },
        dashboard: {
            anonymous: {
                add: 'Add an Anonymous Interaction',
                note: 'Notes for New Anonymous',
            },
            done: 'Done',
            edit_org_order: 'Edit Organization Order',
            edit_org_order_help:
                'Want to customize your view? Press <ng-md-icon icon="editOrder"></ng-md-icon> above to reorder and hide ministries.',
            error_archiving_person:
                'Error archiving person! Please try again or contact support.',
            loading_contacts: 'Loading Contacts',
            no_contacts: {
                welcome: 'WELCOME {{name}}!',
            },
            no_contacts_help:
                'When you add a new person <ng-md-icon icon="addContact"></ng-md-icon> or someone gets assigned to you, <br> they will show up here.',
            notes_for_new_interaction: 'Notes for new',
            organizations_assigned_to_you: 'Ministries',
            people_assigned_to_you: 'People',
            report_periods: {
                one_month: '1m',
                one_week: '1w',
                one_year: '1y',
                six_months: '6m',
                three_months: '3m',
            },
            show_more: 'Show more',
            snooze_for_24_hours: 'Snooze reminder for 24 hours',
            uncontacted: 'Uncontacted',
        },
        date: {
            day_names: [
                'Sunday',
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
            ],
        },
        error: {
            default_error_message: 'An unknown error occurred',
            messages: {
                assigned_select: {
                    search_people:
                        'Error occurred while loading the assignment choices',
                },
                bulk_message_modal: {
                    send_message: 'Error occurred while trying to send message',
                },
                bulk_transfer_modal: {
                    transfer_contacts:
                        'Error occurred while trying to transfer contacts',
                },
                edit_group_or_label_assignments: {
                    load_groups:
                        "Error occurred while loading the user's groups",
                    load_labels:
                        "Error occurred while loading the user's labels",
                },
                group_members: {
                    add_member:
                        'Error occurred while adding the person to the group',
                    load_member_chunk:
                        'Error occurred while loading the next batch of group members',
                    remove_member:
                        'Error occurred while removing the person from the group',
                },
                groups: {
                    create_group: 'Error occurred while creating the group',
                    delete_group: 'Error occurred while deleting the group',
                    load_leaders:
                        "Error occurred while loading the group's leaders",
                    update_group: 'Error occurred while updating the group',
                },
                http_proxy: {
                    default_network_error: 'An unknown network error occured',
                },
                interactions: {
                    create_interaction:
                        'Error occurred while creating the interaction',
                    delete_interaction:
                        'Error occurred while deleting the interaction',
                    update_interaction:
                        'Error occurred while updating the interaction',
                },
                labels: {
                    create_label: 'Error occurred while creating the label',
                    delete_label: 'Error occurred while deleting the label',
                    update_label: 'Error occurred while updating the label',
                },
                logged_in_person: {
                    load_user:
                        'Error occurred while loading your user information',
                },
                mass_edit: {
                    apply_mass_edit:
                        'Error occurred while mass editing the contacts',
                    load_options: 'Error occurred while loading options',
                    load_relationships: 'Error occurred while loading options',
                },
                merge_winner: {
                    load_users: 'Error occurred while loading the users',
                },
                my_people_dashboard: {
                    load_orgs: 'Error occurred while loading the organizations',
                    load_people: 'Error occurred while loading the people',
                    load_reports: 'Error occurred while loading the reports',
                    update_org_order:
                        'Error occurred while updating the organization order',
                    update_org_visibility:
                        'Error occurred while updating the organization visibility',
                },
                organization: {
                    load_ancestry:
                        "Error occurred while loading the organization's ancestors",
                },
                organization_overview: {
                    load_org_relationships:
                        "Error occurred while loading the organization's groups and surveys",
                },
                organization_overview_people: {
                    load_assignments:
                        'Error occurred while loading the people assigned to these people',
                    load_org_people_count:
                        'Error occurred while loading the number of people in the organization',
                    load_people_chunk:
                        'Error occurred while loading the next batch of people',
                    merge_people: 'Error occurred while merging people',
                },
                organization_overview_suborgs: {
                    load_org_chunk:
                        'Error occurred while loading the next batch of sub-organizations',
                    load_org_suborg_count:
                        'Error occurred while loading the number of sub-organizations in the organization',
                },
                organization_overview_team: {
                    load_org_team_count:
                        'Error occurred while loading the number of team members in the organization',
                    load_team_chunk:
                        'Error occurred while loading the next batch of team members',
                },
                people_filters_panel: {
                    load_filter_stats:
                        'Error occurred while loading the filter counts',
                },
                person: {
                    archive_person: 'Error occurred while archiving the person',
                    get_contact_assignments:
                        'Error occurred while loading load the people this person is assigned to',
                    search: 'Error loading search results',
                },
                person_page: {
                    create_person: 'Error occurred while creating the person',
                    delete_avatar:
                        'Error occurred while removing the profile picture',
                    upload_avatar:
                        'Error occurred while uploading the profile picture',
                },
                person_profile: {
                    delete_relationships:
                        'Error occurred while updating the person',
                    reload_merged_person:
                        'Error occurred while refreshing the person',
                    update_person: 'Error occurred while updating the person',
                },
                preferences_page: {
                    update_preferences:
                        'Error occurred while updating the preferences',
                },
                progressive_list_loader: {
                    load_chunk: 'Error occurred while loading the items',
                },
                reports: {
                    load_org_reports:
                        "Error occurred while loading the organization's reports",
                    load_person_report:
                        "Error occurred while loading the person's report",
                },
                routes: {
                    get_history:
                        "Error occurred while loading the person's history",
                    get_organization:
                        'Error occurred while loading the organization',
                    get_person: 'Error occurred while loading the person',
                },
                template_request: {
                    load_template: 'Error occurred while loading the page',
                },
            },
            retry_instructions: 'Click to retry',
        },
        followup_status: {
            attempted_contact: 'Attempted Contact',
            completed: 'Completed',
            contacted: 'Contacted',
            do_not_contact: 'Do Not Contact',
            uncontacted: 'Uncontacted',
        },
        student_status: {
            not_student: 'Not currently a student',
            middle_school: 'Middle School',
            high_school: 'High School',
            collegiate: 'Collegiate',
            masters_or_doctorate: 'Masters/Doctorate',
        },
        general: {
            add: 'Add',
            address: 'Address',
            address_type: 'Address Type',
            address1: 'Address 1',
            address2: 'Address 2',
            address3: 'Address 3',
            address4: 'Address 4',
            city: 'City',
            country: 'Country',
            archive: 'Archive',
            cancel: 'Cancel',
            close: 'Close',
            loading_more: 'Loading more...',
            message: 'Message:',
            ok: 'OK',
            save: 'Save',
            send: 'Send',
            state: 'State',
            subject: 'Subject:',
            zip: 'Zip',
            female: 'Female',
            male: 'Male',
            other: 'Other',
            required: 'Required',
            help: 'Help',
            delete: 'Delete',
        },
        group: 'Group',
        groups: {
            confirm_delete_group:
                'Are you sure you want to delete "{{group_name}}"?',
            edit: {
                edit_group: 'Editing {{group}}',
            },
            form: {
                from: 'From',
                meets_on: 'On',
                to: 'To',
            },
            index: {
                group_name: 'Group Name',
            },
            members: {
                columns: {
                    name: 'Contacts',
                },
                contacts: 'contacts',
                leader: 'Leader',
                remove_confirm:
                    'Are you sure you want to this member from the group?',
                subtitle: 'Members of "{{group_name}}"',
                title: 'Group Members',
            },
            new: {
                new_group: 'Create a New Group',
            },
            show: {
                leaders: 'Group Leaders',
                location: 'Location',
                meets: 'Meets',
            },
        },
        interactions: {
            delete_confirmation:
                'Are you sure you want to delete this interaction?',
        },
        label: 'Label',
        labels: {
            delete: {
                confirm:
                    'Are you sure you want to delete the "{{label_name}}" label?',
            },
            edit: {
                edit_label: 'Edit Label',
            },
            index: {
                label_name: 'Name',
            },
            new: {
                new_label: 'Create a New Label',
            },
        },
        leader: 'Leader',
        mass_edit: {
            save: 'Edit {{contactCount}} contacts',
            title: 'Edit Contacts',
            unchanged: 'Unchanged',
        },
        member: 'Member',
        merge_winner: {
            merge: 'Merge',
            subtitle:
                'Choose the winner of the merge. The other people will be merged into the winner.',
            title: 'Merge Winner',
            person_fields: {
                first_name: 'First name',
                last_name: 'Last name',
                gender: 'Gender',
                email_addresses: 'Email addresses',
                phone_numbers: 'Phone numbers',
                created_date: 'Person created',
                updated_date: 'Person updated',
            },
            user_fields: {
                id: 'User id',
                username: 'Username',
                created_date: 'User created',
                updated_date: 'User updated',
                login_date: 'Last login',
            },
        },
        messages: {
            length_limit: '{{remaining_characters}} characters left',
            recipients: {
                contacts: '{{contact_count}} contacts',
                organization: 'in organization {{name}}',
                search: 'matching {{search}}',
            },
        },
        ministries: {
            groups: {
                columns: {
                    leaders: 'Leader(s)',
                    location: 'Location',
                    name: 'Groups ({{group_count}})',
                    time: 'Meeting Time',
                },
                header: 'Groups',
                meeting_time: {
                    monthly: 'Monthly on {{day}} {{time}}',
                    sporadically: 'Sporadically',
                    time_range: '{{start}} - {{end}}',
                    weekly: 'Weekly on {{day}}s {{time}}',
                },
                ordinal_suffixes: ['th', 'st', 'nd', 'rd'],
            },
            labels: {
                columns: {
                    name: 'Label Name',
                },
            },
            people: {
                activity: {
                    header: 'Activity',
                },
                archive_hover: 'Archive the selected contacts',
                archive_people_confirm:
                    'Are you sure you want to archive {{contact_count}} contacts?',
                assigned: {
                    header: 'Assigned',
                },
                clear_selection_hover: 'Unselect all of the selected contacts',
                delete_hover: 'Delete the selected contacts',
                delete_people_confirm:
                    'Are you sure you want to delete {{contact_count}} contacts?',
                email_hover: 'Email the selected contacts',
                export_hover: 'Export the selected contacts as CSV',
                gender: 'M/F',
                female: 'F',
                male: 'M',
                other: 'O',
                none: '-',
                header: 'Contacts',
                history: {
                    all: 'All',
                    anonymous: 'Anonymous',
                    header: 'History',
                    interactions: 'Interactions',
                    me: 'Me',
                    note_for_interaction: 'Note for {{interaction}}',
                    notes: 'Notes',
                    surveys: 'Surveys',
                },
                leaders: 'leaders',
                mass_edit_hover: 'Mass edit the selected contacts',
                merge_disabled_hover:
                    'Select between 2 and 4 contacts to merge them',
                merge_hover: 'Merge the selected contacts',
                name: 'Name',
                profile: {
                    header: 'Profile',
                },
                remove_self_confirm:
                    'You are removing yourself. If you continue, you will no longer have access to this ministry.',
                selected_contacts: '{{contactCount}} contacts selected',
                sms_hover: 'Text the selected contacts',
                status: 'Status',
                transfer_hover:
                    'Transfer the selected contacts to another organization',
            },
            roots: 'Ministries',
            suborgs: {
                header: 'Ministries',
            },
            survey_responses: {
                header: 'Survey Responses',
            },
            surveys: {
                header: 'Surveys',
            },
            team: {
                header: 'Team',
            },
            tools: {
                header: 'Tools',
            },
        },
        monthly: 'Monthly',
        nav: {
            about: {
                copyright: 'Copyright',
                title: 'About MissionHub',
            },
            cleanup: 'Organization Cleanup',
            contacts: 'Contacts',
            email_us: 'Email Us',
            goal: 'Goal Tracker',
            groups: 'Groups',
            logout: 'Sign Out',
            manage: 'Manage Organizations',
            my_profile: 'My Profile',
            powered_by_cru: 'Powered by Cru',
            report_movement_indicators: 'Report Movement Indicators',
            search: {
                in: 'in',
            },
            settings: 'Settings',
            snapshot: 'Snapshot View',
            support: 'Support',
            terms: 'Terms of Service',
            trend: 'Trend Tracker',
        },
        organizations: {
            cleanup: {
                confirm_archive:
                    'Are you sure you wanted to archive the desired contacts?',
            },
        },
        people: {
            edit: {
                cancel_create_confirm:
                    'Are you sure you want to discard this unsaved contact?',
                delete_address_confirm:
                    'Are you sure you want to delete this address?',
                delete_email_confirm:
                    'Are you sure you want to delete this email address?',
                delete_phone_confirm:
                    'Are you sure you want to delete this phone number?',
            },
            index: {
                add_address: 'Add Address',
                create_address: 'Create Address',
                edit_address: 'Edit Address',
                labels: 'Labels',
                manage_groups: 'Manage Groups',
                manage_labels: 'Manage Labels',
            },
            search: {
                search_placeholder:
                    'Search for the first name, last name or email.',
            },
            show: {
                apply_groups: 'Assign {{name}} to the following groups.',
                no_groups: 'No groups assigned.',
                no_labels: 'No labels assigned.',
            },
        },
        permissions: {
            admin: 'Admin',
            no_permissions: 'No Permissions',
            user: 'User',
        },
        person_multiselect: {
            no_search_results:
                'No {{people_description}} found matching "{{search}}"',
            search_placeholder: 'Search {{people_description}}',
            searching: 'Searching {{people_description}}...',
        },
        preferences: {
            beta_mode: 'Try out experimental beta features',
            language: 'Language',
            legacy_navigation: 'Revert to legacy navigation',
            no_language_selected: 'Select Language',
            notifications_header: 'When would you like us to let you know?',
            notifications_info: '(Enabled by default)',
            person_assigned: 'When a person is assigned to you',
            person_moved: 'When a person is transferred to your organization',
            refresh_language: 'Refresh To Show Language Changes',
            time_zone: 'Time zone',
            title: 'User Preferences',
            weekly_digest: 'Weekly Ministry Digest',
        },
        search: {
            assignments: {
                title: 'Assigned To',
            },
            groups: {
                title: 'Groups',
            },
            labels: {
                title: 'Labels',
            },
            sidebar: {
                include_archived: 'Include archived contacts',
            },
        },
        signatures: {
            clear: 'Clear filters',
            title: 'Signatures',
        },
        sporadically: 'Sporadically',
        transfer: {
            options: {
                copy_answers: 'Copy survey answers with contact',
                copy_contact: 'Leave a copy of the contact in the organization',
                copy_interactions: 'Copy interactions with contact',
            },
            organizations: 'organizations',
            subtitle:
                'Transfer {{contact_count}} contact(s) to another organization.',
            title: 'Transfer Contacts',
            transfer: 'Transfer {{contact_count}} Contact(s)',
        },
        weekly: 'Weekly',
    },
    surveyTab: {
        createSurvey: 'Create Survey',
        surveyName: 'Survey Name',
        columns: {
            survey: 'Survey',
            contacts: 'Contacts',
            unassigned: 'Unassigned',
            uncontacted: 'Uncontacted',
            keyword: 'Keyword',
            link: 'Link',
            status: 'Status',
        },
        status: {
            live: 'Live',
            off: 'Off',
        },
        menu: {
            edit: 'Edit',
            preview: 'Preview',
            delete: 'Delete',
            copy: 'Copy',
            import: 'Import Survey Results',
        },
        errors: {
            createSurvey: 'Error occurred while creating survey',
            updateSurvey: 'Error occurred while updating survey',
            deleteSurvey: 'Error occurred while deleting survey',
            getStats: 'Error occurred while retrieving survey stats',
        },
    },
    surveys: {
        delete: {
            confirm: 'Are you sure you want to delete this survey?',
        },
        settings: {
            welcome_message: 'Welcome Message',
            success_message: 'Success Message',
            image: 'Image',
            image_upload: 'Upload Image',
        },
        keyword: {
            keyword: 'Keyword',
            keyword_example: 'Example: Cookies',
            instructions:
                'Use at least 3 letters (no special characters/spaces)',
            help:
                'Choosing a keyword for your community or event enables you to have people fill out your survey questions via the web, interactive texting, and smartphones.\n' +
                'They will text your keyword to the number 85005 and your survey questions will appear on their device. Note: The process of acquiring new keywords requires manual intervention.\n' +
                'Once you request your keyword expect to wait up to 24 hours before we notify you via email that your keyword is approved and ready for use.',
            purpose: 'Keyword Purpose',
            purpose_instructions: 'What do you plan to use the keyword for?',
            purpose_example: 'Example: Weekly Meeting',
            response: 'Text Response',
            response_instructions: 'Response must include {{ link }} exactly.',
            response_example:
                'Example: Thanks for taking our survey! Reply with “i” or press {{ link }} if you have a smartphone.',
            request: 'Request Keyword',
            requested: 'Keyword Requested',
            requested_message:
                'We will notify you within 24 hours by email if/when your keyword is approved and ready for use.',
            errors: {
                taken: 'This keyword is taken. Try another.',
                requestKeyword: 'Error occurred while requesting a keyword',
                deleteKeyword: 'Error occurred while deleting a keyword',
            },
        },
        questions: {
            questions: 'Questions',
        },
    },
};
