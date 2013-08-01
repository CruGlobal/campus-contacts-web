class GenerateInteractionTypes < ActiveRecord::Migration
  def up
    InteractionType.delete_all
    execute("INSERT INTO `interaction_types` (`id`, `organization_id`, `name`, `i18n`, `icon`, `created_at`, `updated_at`) VALUES (1, 0, 'Comment Only', 'comment', 'comment.png', '2013-05-02 18:11:59', '2013-05-02 18:11:59'),(2, 0, 'Spiritual Conversation', 'spiritual_conversation', 'spiritual_convo.png', '2013-05-02 18:11:59', '2013-05-02 18:11:59'),(3, 0, 'Personal Evangelism', 'gospel_presentation', 'gospel_pres.png', '2013-05-02 18:11:59', '2013-05-02 18:11:59'),(4, 0, 'Personal Evangelism Decisions', 'prayed_to_receive_christ', 'prc.png', '2013-05-02 18:11:59', '2013-05-02 18:11:59'),(5, 0, 'Holy Spirit Presentation', 'holy_spirit_presentation', 'hs.png', '2013-05-02 18:11:59', '2013-05-02 18:11:59'),(6, 0, 'Graduating on Mission', 'graduating_on_mission', 'grad.png', '2013-05-02 18:11:59', '2013-05-02 18:11:59'),(7, 0, 'Faculty on Mission', 'faculty_on_mission', 'grad.png', '2013-05-02 18:11:59', '2013-05-02 18:11:59');");
  end

  def down
  end
end
