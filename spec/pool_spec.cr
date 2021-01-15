require "spec"
require "../src/pool"

describe Pool do
  it "creates a pool" do
    Pool.new { 0 }
  end

  it "add" do
    i = 0
    pool = Pool.new { i += 1 }
    pool.add 99
    pool.get.should eq 99
  end

  it "get" do
    i = 0
    pool = Pool.new { i += 1 }
    pool.get.should eq 1
  end

  it "get with a block" do
    i = 0
    pool = Pool.new { i += 1 }
    pool.get &.should eq 1
  end

  describe "exceptions" do
    it "doesn't add back an instance if raised" do
      i = 0
      pool = Pool.new { i += 1 }
      pool.add 99
      begin
        pool.get { raise "" }
      rescue
      end
      pool.get.should eq 1
    end

    it "adds back an instance if rescued" do
      i = 0
      pool = Pool.new { i += 1 }
      pool.add 99
      pool.get do
        raise ""
      rescue
      end
      pool.get.should eq 99
    end
  end

  describe "resize" do
    it "grows" do
      i = 0
      pool = Pool.new { i += 1 }
      pool.resize 9
      pool.total_size.should eq 9
    end

    it "shrinks" do
      i = 0
      pool = Pool.new(9) { i += 1 }
      has_yielded = false
      pool.resize 1 { has_yielded = true }
      has_yielded.should be_true
      pool.total_size.should eq 1
    end
  end
end
