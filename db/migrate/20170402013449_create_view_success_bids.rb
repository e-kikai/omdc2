class CreateViewSuccessBids < ActiveRecord::Migration[5.0]
  def change
    execute <<-SQL
      CREATE OR
      REPLACE VIEW view_success_bids AS
      SELECT DISTINCT
          ON (b.product_id) b.*,
          bc.count,
          bs.count AS same_count
      FROM
        bids b
        LEFT JOIN (
          SELECT
            product_id,
            count(*) AS COUNT
          FROM
            bids
          WHERE
            soft_destroyed_at IS NULL
          GROUP BY
            product_id
        ) bc
          ON bc.product_id = b.product_id
        LEFT JOIN (
          SELECT DISTINCT
              ON (product_id) product_id,
            amount,
            count(*) AS COUNT
          FROM
            bids
          WHERE
            soft_destroyed_at IS NULL
          GROUP BY
            product_id,
            amount
          ORDER BY
            product_id DESC,
            amount DESC
        ) bs
          ON bs.product_id = b.product_id
      WHERE
        soft_destroyed_at IS NULL
      ORDER BY
        b.product_id,
        b.amount DESC,
        sameno DESC,
        id ASC;
    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW view_success_bids;
    SQL
  end
end
