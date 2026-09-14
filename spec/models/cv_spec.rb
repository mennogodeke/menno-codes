require "rails_helper"

RSpec.describe Cv, type: :model do
  it "can have a résumé PDF attached" do
    cv = Cv.create!
    cv.resume.attach(
      io: StringIO.new("%PDF-1.4 fake resume"),
      filename: "resume.pdf",
      content_type: "application/pdf"
    )

    expect(cv.resume).to be_attached
  end

  it "has no résumé attached by default" do
    expect(Cv.create!.resume).not_to be_attached
  end
end
