#!/usr/bin/env ruby

require "bundler/setup"
require "csa/ccm/cli"

caiq = YAML.load(IO.read("caiq.yaml"))

domains = caiq["ccm"]["control_domains"]

CONTROLS_ADOC_DIR = "sources/controls"
FileUtils.mkdir_p(CONTROLS_ADOC_DIR)
FileUtils.rm_f(File.join(CONTROLS_ADOC_DIR, "xx-all.adoc"))

version = caiq["ccm"]["metadata"]["version"]
req_namespace = "/ccm/#{version}"
domain_counter = 1

domains_body = domains.each do |domain|
  domain_id = domain["id"]
  domain_name = domain["name"]
  controls = domain["controls"]
  domain_namespace = "#{req_namespace}/#{domain_id.downcase}"

  domain_header = <<~EOF
  .#{domain_name}
  [requirement,type="class",label="#{domain_id}",id="#{domain_namespace}",obligation="requirement"]
  ====
  EOF

  domain_footer = <<~EOF
  ====
  EOF


  controls_body = controls.map do |control|
    control_id = control["id"]
    control_name = control["name"]
    control_spec = control["specification"]

    if control_spec
      # some cleanups
      control_spec = control_spec.gsub("\n", "\n\n")
      control_spec = control_spec.gsub('• ', "\n* ")
    end

    control_number = control_id.split("-").last
    control_namespace = "#{domain_namespace}/#{control_number}"

    control_header = <<~EOF
    .#{control_name}
    [requirement,type="general",label="#{control_id}",id="#{control_namespace}"]
    ======
    #{control_spec}
    EOF

    control_footer = <<~EOF
    ======
    EOF

    questions = control["questions"]

    questions_adoc = questions.map do |question|
      # puts question

      question_id = question["id"]
      question_content = question["content"]
      question_number = question_id.split(".").last
      question_namespace = "#{control_namespace}/questions/#{question_number}"

      question_adoc = <<~EOF
      [verification,type="general",label="#{question_id}",id="#{question_namespace}"]
      --
      #{question_content}
      --
      EOF
    end.join("\n")

    controls_adoc = [control_header, questions_adoc, control_footer].join("\n")

    controls_adoc
  end.join("\n")


  File.open(File.join(CONTROLS_ADOC_DIR, "#{"%02d" % domain_counter}-#{domain_id.downcase}.adoc"),"w") do |f|
    f.write [domain_header, controls_body, domain_footer].join("\n")
  end

  filename = "#{"%02d" % domain_counter}-#{domain_id.downcase}.adoc"

  File.open(File.join(CONTROLS_ADOC_DIR, "xx-all.adoc"),"a") do |f|
    f.write "include::#{filename}[]\n"
  end


  domain_counter = domain_counter + 1
end

# domains_adoc = domain_header + domains_body + domain_footer

